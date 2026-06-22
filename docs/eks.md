# EKS

## Création infrastructure EKS


Cette infrastructure est détruite après les tests avec terraform destroy afin de limiter les coûts AWS, notamment ceux liés au NAT Gateway, aux nodes EC2 et au control plane EKS.
https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks#configure-kubectl


```shell
# Terminal
cd infra/eks
make check
make deploy
```

Au besoin, installer kubectl

```shell
# Terminal
sudo snap install kubectl --classic
```

Puis, configurer kubectl

```shell
# Terminal
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```

La hiérarchie créée est 

```shell
Cluster EKS
│
└── Node Group
     │
     ├── EC2 #1
     └── EC2 #2
```

### Principales commandes

Pour lister les nodes 

```shell
# Terminal
kubectl get nodes
```

Pour lister les nodes group 

```shell
# Terminal
aws eks list-nodegroups --region us-east-1 --cluster-name microcrm-eks
```

Puis, pour voir le détail du group

```shell
# Terminal
aws eks describe-nodegroup --region us-east-1 --cluster-name microcrm-eks --nodegroup-name microcrm_nodes-20260619125601806300000001
```

Pour voir les instances EC2 créées 

```shell
# Terminal
aws ec2 describe-instances \
   --region us-east-1 \
   --filters "Name=tag:eks:cluster-name,Values=microcrm-eks" \
   --query "Reservations[].Instances[].{id:InstanceId,state:State.Name,type:InstanceType,subnet:SubnetId,privateIp:PrivateIpAddress}"
```

### POC rapide pour vérifier que tout est ok

Créer un namespace

```shell
kubectl create namespace hello
```

Déployer une image hello/nginx

```shell
kubectl create deployment hello-nginx --image=nginx:latest --replicas=3 -n hello
```

Vérifier les pods

```shell
kubectl get pods -n hello -o wide
```

Exposer le service

```shell
kubectl expose deployment hello-nginx --type=LoadBalancer --port=80 --target-port=80 -n hello
```

Récupérer l'ip public

```shell
kubectl get svc -n hello
```

Tester

```shell
curl http://<EXTERNAL-IP>
```

Tester la résilience

Afficher les pods 

```shell
kubectl get pods -n hello
```

Puis en supprimer 1

```shell
kubectl delete pod <nom-du-pod> -n hello
```

Vérifier ensuite qu'il en recréé bien 1

```shell
kubectl get pods -n hello
```
