provider "aws" {
  region  = var.region
  profile = "default"
}

terraform {
  required_version = ">=v0.13.2"

backend "s3" {
  region = "us-east-2"
  bucket = "haplate-hqr"
  key = "env/format/terraform.tfstate"
  encrypt = true
}
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=3, <4"
    }
  }
}
