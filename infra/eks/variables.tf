variable "environment" {
  type = string
  description = "Deployment environment (staging, prod)." 
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
}

variable "cluster_config" {
  type = object({
    name    = string
    version = string
  })  
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."  
}

variable "common_tags" {
  type = object({
    Project     = string
    Environment = string
    ManagedBy   = string
  })  
}

variable "node_groups" {
  type = list(object({
    name           = string
    instance_types = list(string)
    ami_type       = string
    capacity_type  = string
    disk_size      = number

    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })

    update_config = object({
      max_unavailable = number
    })
  }))
}

variable "networking" {
  type = object({
    cidr_block      = string
    region          = string
    vpc_name        = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
    single_nat_gateway = bool
  })  
}

variable "security_groups" {
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
    egress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
  }))
  default = [{
    name        = "project6-security-group"
    description = "Inbound & Outbound traffic for project6-security-group"
    ingress = [
      {
        description      = "Allow HTTPS"
        protocol         = "tcp"
        from_port        = 443
        to_port          = 443
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = null
      },
      {
        description      = "Allow HTTP"
        protocol         = "tcp"
        from_port        = 80
        to_port          = 80
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = null
      },
    ]
    egress = [
      {
        description      = "Allow all outbound traffic"
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    ]
  }]
}