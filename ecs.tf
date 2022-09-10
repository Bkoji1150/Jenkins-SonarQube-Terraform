
terraform {
  required_version = ">=1.1.5"

  backend "s3" {
    bucket         = "hqr.common.database.module.kojitechs.tf"
    dynamodb_table = "terraform-lock"
    key            = "path/env"
    region         = "us-east-1"
    encrypt        = "true"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.aws_account_id, terraform.workspace)}:role/Role_For-S3_Creation"
  }
  default_tags {
    tags = module.required_tags.aws_default_tags
  }
}

data "terraform_remote_state" "operational_environment" {
  backend = "s3"

  config = {
    region = "us-east-1"
    bucket = "operational.vpc.tf.kojitechs"
    key    = format("env:/%s/path/env", terraform.workspace)
  }
}

data "terraform_remote_state" "recipe_db_cluster_secrets" {
  backend = "s3"

  config = {
    region = "us-east-1"
    bucket = "ecs.terraform.cluster.terraform"
    key    = format("env:/%s/path/env", terraform.workspace)
  }
}


locals {
  operational_state = data.terraform_remote_state.operational_environment.outputs
  vpc_id            = local.operational_state.vpc_id
  public_subnet     = local.operational_state.public_subnets
  private_subnets   = local.operational_state.private_subnets
  db_subnets_names  = local.operational_state.db_subnets_names
  cluster_name      = var.cluster_name == null ? upper(format("HQR-%s-HOST", var.tier)) : var.cluster_name

  # Database info 
  recipe_db_cluster_secrets = data.terraform_remote_state.recipe_db_cluster_secrets.outputs
  cluster_endpoint          = local.recipe_db_cluster_secrets.cluster_endpoint
  cluster_database_name     = local.recipe_db_cluster_secrets.cluster_database_name
  cluster_database_port     = local.recipe_db_cluster_secrets.cluster_database_port
  cluster_database_user     = local.recipe_db_cluster_secrets.cluster_database_user
  cluster_database_password = local.recipe_db_cluster_secrets.cluster_database_secrets

  ecs = [
    {
      from_port = var.container_port
      to_port   = var.container_port
      protocol  = "tcp"
      security_groups = [
        aws_security_group.lb.id
      ]
    }
  ]
}

resource "aws_security_group" "ecs" {
  name        = "ecs_security_group"
  description = format("%s-%s-%s", var.cell_name, var.component_name, "ecs_Sucurity_Group")
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = local.ecs

    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_region" "current" {}

module "required_tags" {
  source = "git::https://github.com/Bkoji1150/kojitechs-tf-aws-required-tags.git?ref=v1.0.0"

  line_of_business        = var.line_of_business
  ado                     = var.ado
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = var.tech_poc_primary
  tech_poc_secondary      = var.builder
  application             = var.application
  builder                 = var.builder
  application_owner       = var.application_owner
  vpc                     = var.vpc
  cell_name               = var.cell_name
  component_name          = var.component_name
}


module "microservice" {
  source = "./ecs" #"git::git@github.com:Bkoji1150/hqr-operational-enviroment.git//ecs" # git::git@github.com:Bkoji1150/hqr-operational-enviroment.git//

  vpc_id           = local.vpc_id
  tier             = var.service_tier
  ecs_service_name = lower(format("%s-%s", var.cell_name, var.component_name))
  container_name   = var.container_name
  component_name   = var.component_name
  container_port   = var.container_port

  create_target_group           = false
  target_group_arn              = aws_lb_target_group.api.arn
  lb_listener_paths             = [var.target_group_health_check_path]
  lb_listener_arn               = aws_lb_listener.api.arn
  task_definition_task_role_arn = aws_iam_role.app_iam_role.arn

  ecs_service_subnet_ids    = local.private_subnets
  ecs_service_sg_ids        = [aws_security_group.ecs.id]
  ecs_service_desired_count = var.ecs_service_desired_count

  container_port_mappings = [{
    containerPort = var.container_port
    hostPort      = var.container_port
    protocol      = "tcp"
  }]

  container_log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-create-group"  = "true"
      "awslogs-group"         = var.component_name
      "awslogs-region"        = var.aws_region
      "awslogs-stream-prefix" = "ecs-api"
    }
    secretOptions = null
  }
  container_environment_variables = [
    {
      name  = "DJANGO_SECRET_KEY"
      value = var.django_secret_key
    },
    {
      name  = "DB_HOST"
      value = local.cluster_endpoint
    },
    {
      name  = "DB_NAME"
      value = local.cluster_database_name
    },
    {
      name  = "DB_USER"
      value = local.cluster_database_user
    },
    {
      name  = "DB_PASS"
      value = local.cluster_database_password
    },
    {
      name  = "ALLOWED_HOSTS"
      value = aws_route53_record.app.fqdn
    },
    {
      name  = "S3_STORAGE_BUCKET_NAME"
      value = aws_s3_bucket.app_public_files.bucket
    },
    {
      name  = "S3_STORAGE_BUCKET_REGION"
      value = data.aws_region.current.name
    }
  ]
  container_mount_points = [
    {
      readOnly      = false,
      containerPath = "/vol/web",
      sourceVolume  = "static"
    }
  ]
}
