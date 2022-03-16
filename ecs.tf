
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
  source = "git::git@github.com:Bkoji1150/hqr-operational-enviroment.git//ecs" # git::git@github.com:Bkoji1150/hqr-operational-enviroment.git//

  vpc_id            = local.operational_environment
  tier              = var.service_tier
  cfqn_name         = format("%s-%s", var.cell_name, var.component_name)
  component_name    = var.component_name
  container_port    = var.container_port
  container_version = var.container_image_version
  container_source  = var.container_image_source
  #  name                           = var.service_tier

  ecs_service_subnet_ids         = local.subnet_ids
  cluster_name                   = module.microservice.ecs_cluster_name
  ecs_service_sg_ids             = [aws_security_group.ecs.id]
  ecs_service_desired_count      = var.ecs_service_desired_count
  lb_listener_paths              = [var.lb_listener_path]
  lb_listener_arn                = module.microservice.target_group_arn
  target_group_health_check_path = var.target_group_health_check_path
  container_name                 = var.component_name
  assign_public_ip               = true

  container_image_source  = "ecr"
  container_image_version = var.container_image_version

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
    {
      name  = "ENV"
      value = lower(terraform.workspace)
    }
  ]
}
