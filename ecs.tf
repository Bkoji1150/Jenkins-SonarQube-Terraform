
data "aws_iam_role" "ecs_role" {
  name = "AWSServiceRoleForECS"
}

locals {
  operational_environment     = aws_vpc.fleur-vpc[0].id
  subnet_ids                  = aws_subnet.fleur-public-subnet.*.id
  operational_environment_ecr = "735972722491.dkr.ecr.us-east-1.amazonaws.com/aws-eksnginx"
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "HQR-PROCESS-HOST"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    Environment = "Development"
  }
}

module "alb" {
  source                            = "git::git@github.com:Bkoji1150/3-TIER-TARRAFORM-PROJECT.git//loadbalancing"
  public_sg                         = [aws_security_group.fleur-public-security-group.id]
  public_subnets                    = aws_subnet.fleur-public-subnet.*.id
  tg_port                           = 80 # 0
  tg_portocol                       = "HTTP"
  vpc_id                            = aws_vpc.fleur-vpc[0].id
  Project-Omega_healthy_threshold   = 2
  Project-Omega_unhealthy_threshold = 2
  lb_timeout                        = 3
  lb_interval                       = 30
  listener_port                     = 80
  listener_protocol                 = "HTTP"
}

resource "aws_security_group" "ecs" {
  name        = "ecs_security_group"
  description = format("%s-%s-%s", var.cell_name, var.component_name, "ecs_Sucurity_Group")
  vpc_id      = aws_vpc.fleur-vpc[0].id

  dynamic "ingress" {
    for_each = local.ecs
    iterator = pr

    content {
      description = pr.value.description
      from_port   = pr.value.from_port
      to_port     = pr.value.to_port
      protocol    = pr.value.protocol
      cidr_blocks = pr.value.cidr_blocks
    }
  }
}

module "microservice" {
  source = "./ecs"

  vpc_id                         = local.operational_environment
  tier                           = "APP"
  cfqn_name                      = format("%s-%s", var.cell_name, var.component_name)
  component_name                 = var.component_name
  container_port                 = var.container_port
  container_version              = var.container_image_version
  container_source               = var.container_image_source
  ecs_service_subnet_ids         = local.subnet_ids
  cluster_name                   = module.ecs.ecs_cluster_name
  ecs_service_sg_ids             = [aws_security_group.ecs.id]
  ecs_service_desired_count      = var.ecs_service_desired_count
  lb_listener_paths              = [var.lb_listener_path]
  lb_listener_arn                = module.alb.loadBalancingSecurityGroup
  target_group_health_check_path = var.target_group_health_check_path
  container_name                 = var.component_name
  container_image                = local.operational_environment_ecr
  container_image_source         = var.container_image_source
  container_image_version        = var.container_image_version

  container_port_mappings = [{
    containerPort = var.container_port
    hostPort      = var.container_port
    protocol      = "tcp"
  }]

  container_log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-create-group"  = "true"
      "awslogs-group"         = format("/%s/%s", var.cell_name, var.component_name)
      "awslogs-region"        = var.aws_region
      "awslogs-stream-prefix" = "ecs"
    }
    secretOptions = null
  }

  container_environment_variables = [
    # {
    #  name = "BASE_PATH"
    #  value = var.base_path
    # },
    {
      name  = "ENV"
      value = lower(terraform.workspace)
    }
    # {
    #  name = "HARP_DOMAIN"
    #  value = terraform.workspace == "prod" ? “hqr.cms.gov” : “hqr-${terraform.workspace}.hcqis.org”
    # },
    # {
    #  name = “HARP_URL”
    #  value = “https://${local.harp_env}harp.cms.gov”
    # },
    # {
    #  name = “LOGOUT_URL”
    #  value = var.logout_url
    # },
    # {
    #  name = “SERVER_PORT”
    #  value = var.container_port
    # },
    # {
    #  name = “SFT_URL”
    #  value = var.sft_url
    # },
    # {
    #  name = “STRAPI_API_URL”
    #  value = “https://cms${local.strapi_env}.hqr${local.strapi_env}.hcqis.org”
    # }

  ]
}
