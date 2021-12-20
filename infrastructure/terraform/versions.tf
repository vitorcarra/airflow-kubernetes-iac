terraform {
  required_version = ">= 0.13.1"

  backend "s3" {
    bucket = "camara-terraform-bucket"
    key = "terraform/terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws        = ">= 3.22.0"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = ">= 1.13"
  }
}