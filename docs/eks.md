# EKS

## Création infrastructure EKS


Cette infrastructure est détruite après les tests avec terraform destroy afin de limiter les coûts AWS, notamment ceux liés au NAT Gateway, aux nodes EC2 et au control plane EKS.
https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks#configure-kubectl

### Configurer kubectl

A exécuter après le déploiement en local pour pouvoir interagir avec le cluster

Pour staging

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-staging
```

Pour prod

```shell
# Terminal
aws eks update-kubeconfig --region us-east-1 --name project6-eks-prod
```

### Principales commandes

Pour lister les nodes 

```shell
# Terminal
kubectl get nodes
```

