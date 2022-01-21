provider "aws" {
  region  = var.region
  profile = "default"
}

terraform {
  required_version = "v1.1.3"

  backend "s3" {
    region  = "us-east-2"
    bucket  = "haplate-hqr"
    key     = "env/format/terraform.tfstate"
    encrypt = true
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    postgresql = {
      source = "terraform-providers/postgresql"
    }
  }
  # required_version = ">= 0.13"
}