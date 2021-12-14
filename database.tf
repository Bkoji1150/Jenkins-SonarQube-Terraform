
resource "random_string" "master_user_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "master_secret" {
  # for_each = local.common_secret_values
  name        = "master_secret" # TODO
  description = "secret to manage the  master credentials on the ${var.db_clusters.identifier}"
  tags        = {}
}

resource "aws_secretsmanager_secret_version" "master_secret_value" {
  secret_id     = aws_secretsmanager_secret.master_secret.id
  secret_string = jsonencode(merge(local.common_secret_values, { username = var.db_clusters.dbname, password = random_string.master_user_password.result }))
}

# resource "aws_secretsmanager_secret_version" "user_secret_value" {
#   secret_id     = aws_secretsmanager_secret.user_secret_value[each.key].id
#   secret_string = jsonencode(merge(local.common_secret_values, {username =var.db_clusters.dbname, password = random_string.master_user_password.result }))
# }

# resource "aws_secretsmanager_secret" "user_secret" {
#  for_each = toset(var.username_taneble) 
#  description = "secret to manage the ${var.username_taneble} master credentials on the ${var.identifier}"
#   name = "user_secret" # TODO 
#   tags = {
#       Name = "user_secret"
#   }
# }

resource "aws_db_instance" "postgres_rds" {

  allocated_storage      = var.db_storage
  engine                 = var.db_clusters.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  name                   = var.db_clusters.name
  port                   = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["port"]
  username               = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["dbname"]
  password               = random_string.master_user_password.result
  parameter_group_name   = aws_db_parameter_group.Postgres_parameter_group.id
  vpc_security_group_ids = [aws_security_group.fleur-private-security-group.id]
  identifier             = var.db_clusters.identifier
  skip_final_snapshot    = var.skip_db_snapshot
  db_subnet_group_name   = aws_db_subnet_group.flour_rds_subnetgroup[0].id
  multi_az               = var.multi_az

  tags = {}
  lifecycle {
    ignore_changes = [
      identifier,
      engine_version,
      engine
    ]
  }
}

provider "postgresql" {
  alias     = "pgconnect"
  host      = aws_db_instance.postgres_rds.address
  port      = aws_db_instance.postgres_rds.port
  username  = var.db_clusters.dbname
  password  = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  superuser = false
  sslmode   = "disabled"
}

# resource  "postgresql_role"  "users" {
#     for_each = toset(var.db_users)
#     name = each.key
#     login = true 
#     encrypted_password = true 
#     password = var.db_initial_id
#     #  deponds_on = [aws_db_instance.postgres_rds.id]
# }

# resource "postgresql_role"  "tenable_user" {
#    count = var.create_tenable_user ? 1 : 0
#     name = var.tenable_user
#     login = true 
#     encrypted_password = true 

#     password = var.db_user_password
#     # deponds_on = [aws_db_instance.postgres_rds]
# } 
# resource "postgresql_grant" "users_prilages" {
#     for_each = {
#         for idx, user_privileges in var.db_users_privileges : idx => user_privileges
#         if contains(var.db_users, user_privileges.user)
#     }
#   database    = var.db_clusters.bname
# #   role        = each.value.user
# #   schema      = each.value.privileges 
#    privileges  = ["SELECT"]
#   role        = "test_role"
#   schema      = "public"
#   object_type = "table"
# #   objects     = ["table1", "table2"]
#   depends_on = [
#     postgresql_role.users
#   ]
# }

resource "aws_db_parameter_group" "Postgres_parameter_group" {
  name   = "postgresrds"
  family = "postgres10"


  parameter {
    name         = "log_connections"
    value        = 1
    apply_method = "immediate"
  }
  lifecycle {
    create_before_destroy = true
  }
}