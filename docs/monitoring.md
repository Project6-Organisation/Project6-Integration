## Pour rafraichir les dashboards Grafana

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

## Pour accéder aux données Prometheus/Pushgateway

Depuis une console

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