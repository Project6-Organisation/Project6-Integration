# EKS

Cette infrastructure est détruite après les tests avec terraform destroy afin de limiter les coûts AWS, notamment ceux liés au NAT Gateway, aux nodes EC2 et au control plane EKS.

## Création infrastructure EKS

```shell
# Terminal
cd infra/eks
make check
make deploy
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
