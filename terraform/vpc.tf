variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = "us-east-2"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "Terraform": true
  }

  public_subnet_tags = {
    "Terraform": true
  }

  private_subnet_tags = {
    "Terraform": true
  }
}
