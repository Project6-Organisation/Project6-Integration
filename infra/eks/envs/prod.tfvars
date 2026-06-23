environment   = "prod"
naming_prefix = "project6-EKS-PROD"

cluster_config = {
  name    = "project6-eks-prod"
  version = "1.32"
}

common_tags = {
  Project     = "Project6"
  Environment = "prod"
  ManagedBy   = "Terraform"
}

node_groups = [
  {
    name           = "project6-EKS-PROD-NodeGroup"
    instance_types = ["t3.medium"]
    ami_type       = "AL2023_x86_64_STANDARD"
    capacity_type  = "ON_DEMAND"
    disk_size      = 20

    scaling_config = {
      desired_size = 2
      min_size     = 2
      max_size     = 4
    }

    update_config = {
      max_unavailable = 1
    }
  }
]