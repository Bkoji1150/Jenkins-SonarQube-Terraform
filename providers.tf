provider "aws" {
  region = var.region
  # assume_role {
  #   role_arn = "${var.account_role}"
  #   session_name = "Terraform_build_role"
  profile = "default"
  # default_tags {
  #    tags = local.default_tags
  #  }
}



terraform {
  required_version = ">=v0.13.2"

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

  required_version = ">= 0.13"
}