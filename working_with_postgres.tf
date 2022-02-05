provider "postgresql" {
  alias            = "pgconnect"
  host             = aws_db_instance.postgres_rds.address
  port             = aws_db_instance.postgres_rds.port
  username         = var.db_clusters.dbname
  password         = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  superuser        = false
  sslmode          = "require"
  expected_version = aws_db_instance.postgres_rds.engine_version
  connect_timeout  = 15
}

resource "postgresql_database" "postgres" {

  for_each          = toset(var.databases_created)
  provider          = postgresql.pgconnect
  name              = each.key
  allow_connections = true
  depends_on        = [aws_db_instance.postgres_rds]
}

resource "postgresql_role" "users" {
  provider   = postgresql.pgconnect
  for_each   = toset(var.db_users)
  name       = each.key
  login      = true
  password   = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  depends_on = [aws_db_instance.postgres_rds]
}

resource "postgresql_grant" "user_privileges" {
  provider = postgresql.pgconnect
  for_each = {
    for idx, user_privileges in var.db_users_privileges : idx => user_privileges
    if contains(var.db_users, user_privileges.user)
  }
  database    = aws_db_instance.postgres_rds.name
  role        = each.value.user
  privileges  = each.value.privileges
  object_type = each.value.type
  schema      = each.value.type == "database" && each.value.schema == "" ? null : each.value.schema
  objects     = each.value.type == "database" || each.value.type == "schema" ? null : each.value.objects
  depends_on  = [postgresql_role.users]
}
