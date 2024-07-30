variable "aws_region" {
  description = "AWS region" # Description of the variable
  type        = string       # Type of the variable
  default     = "us-east-1"  # Default value for the variable
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC" # Description of the variable
    type        = string                  # Type of the variable
    default     = "100.0.0.0/16"          # Default value for the variable
  
}