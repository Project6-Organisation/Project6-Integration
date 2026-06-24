################################################################################
# POC to check if everything is ok
################################################################################

# module "poc" {
#   source      = "./modules/poc"
#   environment = var.environment
# }

################################################################################
# Create VPC and components
################################################################################

module "vpc" {
  source          = "./modules/vpc"
  networking      = var.networking
  security_groups = var.security_groups
  common_tags     = local.common_tags
  naming_prefix   = local.naming_prefix
  cluster_name    = var.cluster_config.name
}

################################################################################
# Create EKS Cluster and Node Groups
################################################################################

module "eks" {
  source             = "./modules/eks"
  public_subnets_id  = module.vpc.public_subnets_id
  private_subnets_id = module.vpc.private_subnets_id
  security_groups_id = module.vpc.security_groups_id
  cluster_config     = var.cluster_config
  common_tags        = local.common_tags
  naming_prefix      = local.naming_prefix
  node_groups        = var.node_groups
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
}

################################################################################
# Update kubeconfig with created cluster
################################################################################

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_config.name}"
  }
  depends_on = [module.eks]
}