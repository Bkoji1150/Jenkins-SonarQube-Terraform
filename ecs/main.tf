
locals {
  cluster_name = var.cluster_name == null ? upper(format("HQR-%s-HOST", var.tier)) : var.cluster_name
  network_configuration = var.container_launch_type == "FARGATE" ? [{
    subnets          = var.ecs_service_subnet_ids
    security_groups  = var.ecs_service_sg_ids
    assign_public_ip = false
  }] : []
  target_group_stickiness = var.target_group_stickiness == null ? [] : [var.target_group_stickiness]
  # If we pass in a json key for a Secrets Manager secret, we need to strip it off for the IAM policy
  _container_secrets_arns = [for v in var.container_secrets : v.valueFrom]
  container_secrets = [
    for v in local._container_secrets_arns : length(split(":secret:", v)) > 1 ? join(":secret:", [split(":secret:", v)[0], split(":", split(":secret:", v)[1])[0]]) : v
  ]
}

data "aws_iam_policy_document" "task_execution_secrets_policy_document" {
  dynamic "statement" {
    for_each = local.container_secrets
    content {
      effect = "Allow"
      actions = [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ]
      resources = [statement.value]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_execution_role" {

  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.iam_for_ecs.name
  policy_arn = aws_iam_policy.ecs.arn
}

resource "aws_iam_role" "iam_for_ecs" {
  name_prefix        = "iam_for_ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

module "container_definition" {
  source                       = "../container-definition"
  container_name               = var.container_name
  container_image              = var.container_image
  container_version            = var.container_image_version
  container_source             = var.container_image_source
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  port_mappings                = var.container_port_mappings
  container_cpu                = var.container_cpu
  essential                    = var.essential
  environment                  = var.container_environment_variables
  secrets                      = var.container_secrets
  log_configuration            = var.container_log_configuration
  command                      = var.container_command
  ulimits                      = var.container_ulimits
  mount_points                 = var.container_mount_points
  linux_parameters             = var.container_linux_parameters
  entrypoint                   = var.container_entrypoint
  working_directory            = var.container_working_directory
  readonly_root_filesystem     = var.container_readonly_root_filesystem
  dns_servers                  = var.container_dns_servers
  repository_credentials       = var.container_repository_credentials
  links                        = var.container_links
  volumes_from                 = var.container_volumes_from
  user                         = var.container_user
  container_depends_on         = var.container_container_depends_on
  privileged                   = var.container_privileged
  healthcheck                  = var.container_healthcheck
  firelens_configuration       = var.container_firelens_configuration
  docker_labels                = var.container_docker_labels
  start_timeout                = var.container_start_timeout
  stop_timeout                 = var.container_stop_timeout
  system_controls              = var.container_system_controls
  ecr_account_id               = var.ecr_account_id
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.cfqn_name
  container_definitions = module.container_definition.json

  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = [var.container_launch_type]
  network_mode             = var.container_network_mode
  execution_role_arn       = aws_iam_role.iam_for_ecs.arn
  task_role_arn            = var.task_definition_task_role_arn

  dynamic "volume" {

    for_each = var.container_volumes
    content {
      name = volume.value.name
      efs_volume_configuration {
        file_system_id     = volume.value.efs_volume_configuration.file_system_id
        root_directory     = volume.value.efs_volume_configuration.root_directory
        transit_encryption = volume.value.efs_volume_configuration.transit_encryption
        authorization_config {
          access_point_id = volume.value.efs_volume_configuration.authorization_config.access_point_id
          iam             = volume.value.efs_volume_configuration.authorization_config.iam
        }
      }

    }
  }
}

resource "aws_ecs_service" "ecs_service" {
  name                               = var.cfqn_name
  cluster                            = local.cluster_name
  task_definition                    = aws_ecs_task_definition.task_definition.arn
  desired_count                      = var.ecs_service_desired_count
  health_check_grace_period_seconds  = var.target_group_health_check_grace_period_seconds
  launch_type                        = var.container_launch_type
  platform_version                   = var.fargate_platform_version
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  propagate_tags                     = "SERVICE"

  dynamic "network_configuration" {
    for_each = local.network_configuration
    content {
      subnets          = network_configuration.value["subnets"]
      security_groups  = network_configuration.value["security_groups"]
      assign_public_ip = network_configuration.value["assign_public_ip"]
    }
  }

  load_balancer {
    target_group_arn = coalesce(var.target_group_arn, aws_lb_target_group.target_group[*].arn...)
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = var.deployment_controller
  }
}

resource "aws_lb_target_group" "target_group" {
  count                         = var.create_target_group ? 1 : 0
  name                          = lower(format("%s-tg", substr(var.component_name, 0, 29)))
  vpc_id                        = var.vpc_id
  port                          = var.container_port
  protocol                      = var.target_group_protocol
  target_type                   = var.container_launch_type == "FARGATE" ? "ip" : "instance"
  deregistration_delay          = var.target_group_deregistration_delay
  load_balancing_algorithm_type = var.target_group_load_balancing_algorithm_type
  health_check {
    interval            = var.target_group_health_check_interval
    path                = var.target_group_health_check_path
    protocol            = var.target_group_protocol
    port                = var.target_group_health_check_port
    matcher             = var.target_group_health_check_matcher
    timeout             = var.target_group_health_check_timeout
    healthy_threshold   = var.target_group_healthy_threshold_count
    unhealthy_threshold = var.target_group_unhealthy_threshold_count
  }
  dynamic "stickiness" {
    for_each = local.target_group_stickiness
    content {
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      enabled         = stickiness.value.enabled
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener_rule" "cell_lb_listener_rule" {
  count        = var.create_listener_rule ? 1 : 0
  listener_arn = var.lb_listener_arn
  action {
    target_group_arn = coalesce(var.target_group_arn, aws_lb_target_group.target_group[*].arn...)
    type             = "forward"
  }
  condition {
    path_pattern {
      values = var.lb_listener_paths
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "container_cpu" {
  alarm_name          = lower(format("%s-%s-CPU-utilization-greater-than-90", local.cluster_name, var.component_name))
  alarm_description   = "Alarm if cpu utilization greater than 90%"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Maximum"
  period              = "60"
  evaluation_periods  = "3"
  threshold           = "90"
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    cluster_name = local.cluster_name
    service_name = var.cfqn_name
  }
}

resource "aws_cloudwatch_metric_alarm" "container_cpu_reservation" {
  alarm_name          = lower(format("%s-%s-CPU-reservation-greater-than-90", local.cluster_name, var.component_name))
  alarm_description   = "Alarm if cpu reservation greater than 90%"
  namespace           = "AWS/ECS"
  metric_name         = "CPUReservation"
  statistic           = "Maximum"
  period              = "60"
  evaluation_periods  = "3"
  threshold           = "90"
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    cluster_name = local.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "container_memory_utilization" {
  alarm_name          = lower(format("%s-%s-Memory-utilization-greater-than-95", local.cluster_name, var.component_name))
  alarm_description   = "Alarm if memory utilization greater than 95%"
  namespace           = "AWS/ECS"
  metric_name         = "instance_memory_utliization"
  statistic           = "Maximum"
  period              = "60"
  evaluation_periods  = "3"
  threshold           = "95"
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    cluster_name = local.cluster_name
    service_name = var.cfqn_name
  }
}

resource "aws_cloudwatch_metric_alarm" "container_memory_reservation" {
  alarm_name          = lower(format("%s-%s-Memory-reservation-greater-than-95", local.cluster_name, var.component_name))
  alarm_description   = "Alarm if memory reservation greater than 95%"
  namespace           = "AWS/ECS"
  metric_name         = "MemoryReservation"
  statistic           = "Maximum"
  period              = "60"
  evaluation_periods  = "3"
  threshold           = "95"
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    cluster_name = local.cluster_name
  }
}
