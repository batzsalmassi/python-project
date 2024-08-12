tags = {
  Environment = "development"
  Project     = "python-project"
}
name                 = "python-project"
aws_region           = "us-east-1"
cidr                 = "10.10.0.0/16"
public_subnet_count  = 2
private_subnet_count = 2
enable_dns_hostnames = "true"
enable_dns_support   = "true"