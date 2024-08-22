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
  default = ["10.10.1.0/24", "10.10.3.0/24"]
  type    = list(string)
}

variable "public_subnets" {
  default = ["10.10.2.0/24", "10.10.4.0/24"]
  type    = list(string)
}


variable "instance_type" {
  default = ["t3.2xlarge", "t2.small"]
  type    = list(string)

}

variable "name" {
  default = ["Linux", "Windows Server"]
  type    = list(string)
}


# create ami without ami latest image

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
