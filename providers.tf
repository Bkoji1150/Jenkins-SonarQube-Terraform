
provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::735972722491:role/hrq-test-role"
  }
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  required_version = "v1.1.4"

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
      source = "cyrilgdn/postgresql"
    }
  }
  required_version = ">= v1.1.4"
}

provider "archive" {}
