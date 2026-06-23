environment   = "staging"
naming_prefix = "project6-EKS-STAGING"

cluster_config = {
  name    = "project6-eks-staging"
  version = "1.32"
}

common_tags = {
  Project     = "Project6"
  Environment = "staging"
  ManagedBy   = "Terraform"
}

node_groups = [
  {
    name           = "project6-EKS-STAGING-NodeGroup"
    instance_types = ["t3.medium"]
    ami_type       = "AL2023_x86_64_STANDARD"
    capacity_type  = "ON_DEMAND"
    disk_size      = 20

    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }

    update_config = {
      max_unavailable = 1
    }
  }
]