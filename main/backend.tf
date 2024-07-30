terraform {
  backend "s3" {
    bucket = "sean-terraform-project-bucket-backend"
    key    = "terraform/python-master-project.tfstate"
    region = "us-east-1"
  }
}
