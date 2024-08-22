# Provisers 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

    }

  }
  required_version = ">=1.3.7"
}


provider "aws" {
  region = var.aws_region
}

#---------------modules-------------------#
# create vpc

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                         = "py-prod-proj-vpc"
  cidr                          = var.vpc_cidr
  azs                           = var.azs
  private_subnets               = var.private_subnets
  public_subnets                = var.public_subnets
  enable_nat_gateway            = false
  enable_vpn_gateway            = false
  enable_dns_hostnames          = true
  enable_dns_support            = true
  manage_default_network_acl    = false
  manage_default_security_group = false

}
#---------------security_group-------------------#



resource "aws_security_group" "Allow_services" {
  name        = "PROD"
  description = "global rule"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "All traffic_in"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "traffic in HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # access from any
  }

  ingress {
    description = "traffic in HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # access from any
  }

  egress {
    description = "All traffic_out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#---------------key_pair-------------------#
# create key_pair with private key and public_key

resource "aws_key_pair" "TF-key" {
  key_name   = "TF-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "/Users/sean.salmassi/github-Repos/python-project/TF-key"
}