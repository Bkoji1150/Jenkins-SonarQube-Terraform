
provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::735972722491:role/hrq-test-role"
  }
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
  required_version = ">= v1.1.3"
}

provider "archive" {}
