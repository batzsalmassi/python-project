terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">=1.3.7"
}

# Default provider for CloudGuru AWS sandbox environment
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias      = "personal"
  region     = var.aws_region
  access_key = var.personal_aws_access_key
  secret_key = var.personal_aws_secret_key
}

# VPC Module in CloudGuru AWS sandbox
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                          = "py-prod-proj-vpc"
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
  map_public_ip_on_launch       = true
}

# Security Group in CloudGuru AWS sandbox
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "traffic in HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic_out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair in CloudGuru AWS sandbox
#resource "aws_key_pair" "TF-key" {
 # key_name   = "TF-key"
  #public_key = tls_private_key.rsa.public_key_openssh
#}

#resource "tls_private_key" "rsa" {
 # algorithm = "RSA"
  #rsa_bits  = 4096
#}

#resource "local_file" "TF-key" {
#  content  = tls_private_key.rsa.private_key_pem
#  filename = "/Users/sean.salmassi/github-Repos/python-project/TF-key"
#}

# Data Source for AWS AMI in CloudGuru AWS sandbox
#data "aws_ami" "amazon-linux" {
# most_recent = true
#owners      = ["amazon"]

#filter {
# name   = "name"
#values = ["amzn2-ami-hvm*"]
#}
#}
