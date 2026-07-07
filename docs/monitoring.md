## Appliquer des modifications helm - Application

Afin d'appliquer les nouvelles modifications faites dans les fichiers de settings de l'application (values-prod.yaml et values-staging.yaml):

Ouvrir une commande dans le Project6-Integration/helm:

Pour staging:

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-staging
```

Puis:

```shell
# Terminal
helm upgrade --install microcrm . -f values-staging.yaml --namespace microcrm-staging --create-namespace \ 
  --wait --atomic --timeout 10m \
  --set backend.image.tag=develop-1234567 \
  --set frontend.image.tag=develop-1234567 \
  --set ingress.baseDomain=olivierpflieger.fr \
  --timeout 10m
```

Pour prod: 

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-prod
```

```shell
# Terminal
helm upgrade --install microcrm . -f values-prod.yaml --namespace microcrm-prod --create-namespace \
  --set backend.image.tag=v.1.8.0 \
  --set frontend.image.tag=v.1.8.0 \
  --set ingress.baseDomain=olivierpflieger.fr \
  --timeout 10m
```

## Appliquer des modifications helm - Monitoring Prometheus

Afin d'appliquer les nouvelles modifications faites dans les fichiers de settings sur la partie monitoring Prometheus:

Ouvrir une commande dans le Project6-Integration:

Pour staging:

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-staging
```

Puis,

```shell
# Terminal
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring -f helm/monitoring/monitoring-staging.yaml
```

Pour prod:

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-prod
```

Puis,

```shell
# Terminal
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring -f helm/monitoring/monitoring-prod.yaml
```

Puis, forcer le rollout

```shell
kubectl rollout restart deployment/monitoring-grafana -n monitoring
kubectl rollout status deployment/monitoring-grafana -n monitoring
```


## Appliquer des modifications helm - Monitoring Loki

Afin d'appliquer les nouvelles modifications faites dans les fichiers de settings sur la partie monitoring Loki:

Ouvrir une commande dans le Project6-Integration:

```shell
# Terminal
helm upgrade --install loki grafana/loki --namespace monitoring -f helm/monitoring/loki-values.yaml
```

## Rafraichir les dashboards Grafana

Les dashboards sont localisés dans Project6-Integration\helm\monitoring\dashboards

Une fois le json modifié, ouvrir une commande dans Project6-Integration

```shell
# Terminal
for dashboard in helm/monitoring/dashboards/*.json; do
  name=$(basename "$dashboard" .json)

  kubectl create configmap "grafana-dashboard-$name" \
    --from-file="$dashboard" \
    -n monitoring \
    --dry-run=client -o yaml \
    | kubectl label --local -f - grafana_dashboard=1 -o yaml \
    | kubectl apply -f -
done
```

Puis, restart le pod

```shell
# Terminal
kubectl rollout restart deployment monitoring-grafana -n monitoring
```

Grafana est restart et les modifications prises en compte dans les dashboards

## Accéder aux données Prometheus/Pushgateway

Ouvrir un terminal sur le répertoire /Project6-Integration/helm,

Puis,

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-staging
# ou
aws eks update-kubeconfig --region us-east-1 --name project6-eks-prod
```

```shell
# Terminal
kubectl -n monitoring port-forward svc/pushgateway-prometheus-pushgateway 9091:9091
```

Les données sont disponibles à l'adresse http://localhost:9091

Pour push une métrique manuellement

```shell
# Terminal
cat <<EOF | curl --fail --data-binary @- "http://127.0.0.1:9091/metrics/job/dora/service/microcrm/environment/staging/commit/1234567"
dora_deployment_total 1
dora_deployment_success_total 1
dora_change_failure_total 0
dora_lead_time_seconds 240
EOF
```

## Explication des métriques

### Deployment Frequency (DF) et Lead Time (LD)

DF mesure le nombre de déploiement en PROD sur une période donnée.

LD mesure le temps écoulé entre la date/heure du déploiement effectif et la date/heure du premier commit trouvé dans la merge request

Déclenchement : Merge PR de develop => main

S'applique à la fin du workflow de déploiement en PROD

Push la métrique suivante

```shell
dora_deployment_total         = 1
dora_deployment_success_total = 1
dora_change_failure_total     = 0
dora_lead_time_seconds $LEAD_TIME_SECONDS 
```

### Change Failure Rate (CFR)

Mesure le nombre de rollback par rapport au nombre de déploiement effecutés en PROD

S'applique sur un rollback

Push la métrique suivante

```shell
dora_deployment_total         = 1
dora_deployment_success_total = 0
dora_change_failure_total     = 1
```

### Mean Time To Recover (MTTR)

Le MTTR mesure le temps moyen pour restaurer le service après un incident.

Aucun outil de ticketing n'est en place pour pouvoir calculer correctement cette métrique. Point ouvert..

## Configurer le SMTP serveur pour les alertes Grafana / Prometheus

Le serveur SMTP est configuré dans les fichiers de variables :

Project6-Integration/helm/monitoring/monitoring-staging.yaml

Project6-Integration/helm/monitoring/monitoring-prod.yaml

Les secrets user / password sont à ajouter dans grafana-smtp-secret, de la manière suivante: 

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-staging
ou
aws eks update-kubeconfig --region us-east-1 --name project6-eks-prod
```

kubectl create secret generic grafana-smtp-secret \
  -n monitoring \
  --from-literal=SMTP_USER='user' \
  --from-literal=SMTP_PASSWORD='<password>'
