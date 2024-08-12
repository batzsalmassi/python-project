terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0" # Specify the version constraint as needed
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  name                 = var.name
  cidr                 = var.cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count

  tags = var.tags

}
