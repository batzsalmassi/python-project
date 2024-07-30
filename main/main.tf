provider "aws" {
    region = var.aws_region  # Specify the AWS region to use
}

resource "vpc" "main" {
    cidr_block = var.vpc_cidr_block  # Specify the CIDR block for the VPC
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name  # Specify the name of the VPC
    }
}