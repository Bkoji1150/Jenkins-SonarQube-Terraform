terraform {
  required_version = ">= v1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.49"
    }
  }
}
