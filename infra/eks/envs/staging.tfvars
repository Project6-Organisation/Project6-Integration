environment   = "staging"
naming_prefix = "project6-eks-staging"
aws_region    = "us-east-1"

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
    name           = "project6-eks-staging-NodeGroup"
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

networking = {
  cidr_block         = "10.0.0.0/16"
  region             = "us-east-1"
  vpc_name           = "project6-eks-staging-vpc"
  azs                = ["us-east-1a"]
  public_subnets     = ["10.0.1.0/24"]
  private_subnets    = ["10.0.3.0/24"]
  nat_gateways       = true
  single_nat_gateway = true
}
