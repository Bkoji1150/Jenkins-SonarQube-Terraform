module "db_option_group" {
  source = "./modules/db_option_group"

  create = local.create_db_option_group

  name                     = coalesce(var.option_group_name, var.identifier)
  use_name_prefix          = var.option_group_use_name_prefix
  option_group_description = var.option_group_description
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  options  = var.options
  timeouts = var.option_group_timeouts
  tags     = merge(local.default_tags, var.db_option_group_tags)
}

resource "random_uuid" "shapshot_postfix" {}

resource "random_string" "master_user_password" {
  length  = 16
  special = false
}


locals {
  master_password      = var.create_db_instance && var.create_random_password ? random_string.master_user_password.result : var.password
  db_subnet_group_name = !var.cross_region_replica && var.replicate_source_db != null ? null : coalesce(var.db_subnet_group_name, aws_db_subnet_group.flour_rds_subnetgroup[0].id, var.identifie)

  parameter_group_name_id = var.create_db_parameter_group ? aws_db_parameter_group.Postgres_parameter_group.id : var.parameter_group_name

  create_db_option_group = var.create_db_option_group && var.engine != "postgres"
  option_group           = local.create_db_option_group ? module.db_option_group.db_option_group_id : var.option_group_name

  # db_users        = flatten([for v, k in var.db_users : [for vv in v : merge({ user = k }, vv)]])
  db_tenable_user = "postgres_aa2"
  secrets         = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)
}

resource "aws_secretsmanager_secret" "master_secret" {

  name_prefix             = "master_secret"
  description             = "secret to manage the  ${var.db_clusters.name} application user on ${var.db_clusters.identifier}"
  recovery_window_in_days = 0
  tags = {
    Name = "postgres_master_secret"
  }
}

resource "aws_secretsmanager_secret" "users_secret" {

  for_each                = toset(var.db_users)
  name_prefix             = each.key == var.db_users ? "tenable-${var.name_prefix}" : var.name_prefix
  description             = "secret to manage the  ${each.key} user credentials on ${var.db_clusters.identifier}"
  recovery_window_in_days = 0
  tags = {
    Name = "postgres_master_secret"
  }
}
resource "aws_secretsmanager_secret_version" "master_secret_value" {
  secret_id     = aws_secretsmanager_secret.master_secret.id
  secret_string = jsonencode(merge(local.common_secret_values, { username = var.db_clusters.dbname, password = random_string.master_user_password.result }))
}

resource "aws_secretsmanager_secret_version" "user_secret_value" {
  for_each      = toset(keys(aws_secretsmanager_secret.users_secret))
  secret_id     = aws_secretsmanager_secret.users_secret[each.key].id
  secret_string = jsonencode(merge(local.common_tenable_values, { username = each.key, password = random_string.master_user_password.result }))
}

resource "aws_db_instance" "postgres_rds" {

  allocated_storage = var.db_storage
  engine            = var.db_clusters.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class

  name                   = local.secrets["username"]
  port                   = local.secrets["port"]
  username               = local.secrets["dbname"]
  password               = local.secrets["password"]
  parameter_group_name   = aws_db_parameter_group.Postgres_parameter_group.id
  vpc_security_group_ids = [aws_security_group.fleur-private-security-group.id]

  identifier           = var.db_clusters.identifier
  skip_final_snapshot  = var.skip_db_snapshot
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.flour_rds_subnetgroup[0].id
  multi_az             = var.multi_az

  tags = {}
  lifecycle {
    ignore_changes = [
      identifier,
      engine_version,
      engine,
      password
    ]
  }
}

resource "aws_db_parameter_group" "Postgres_parameter_group" {
  name_prefix = "postgresrds"
  family      = "postgres10"

  parameter {
    name         = "log_connections"
    value        = 1
    apply_method = "immediate"
  }
  lifecycle {
    create_before_destroy = true
  }
}
