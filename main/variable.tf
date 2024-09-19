variable "aws_region" {
  default = "us-east-1"
}


variable "vpc_cidr" {
  default = "10.10.0.0/16"
  type    = string
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
  type    = list(string)

}

variable "private_subnets" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
  type    = list(string)
}

variable "public_subnets" {
  default = ["10.10.3.0/24", "10.10.4.0/24"]
  type    = list(string)
}


variable "instance_type" {
  default = ["t3.2xlarge", "t2.small", "t2.micro", "t2.medium"]
  type    = list(string)

}

variable "name" {
  default = ["Linux", "Windows Server"]
  type    = list(string)
}

#---------------data aws_ami-------------------#
# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Declare the shodan_api_key variable
variable "shodan_api_key" {
  description = "Shodan API key for accessing the API"
  type        = string
  sensitive   = true
  default     = "" # You can set a default value or leave it empty for security reasons
}

variable "personal_aws_secret_key" {
  type      = string
  sensitive = true
}

variable "personal_aws_access_key" {
  type      =       string
  sensitive = true
}