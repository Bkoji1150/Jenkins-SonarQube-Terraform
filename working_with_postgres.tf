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

resource "postgresql_role" "application_role" {
  for_each   = toset(var.db_users) # Only for users that have password and are allowed to login
  name       = each.key
  login      = true
  provider   = postgresql.pgconnect
  depends_on = [aws_db_instance.postgres_rds]
}
resource "postgresql_schema" "my_schema" {
  name     = "cypress_schema"
  owner    = "app_www"
  provider = postgresql.pgconnect
  policy {
    usage = true
    role  = "app_www"
  }

  # app_releng can create new objects in the schema.  This is the role that
  # migrations are executed as.
  policy {
    create = true
    usage  = true
    role   = "app_www"
  }
  policy {
    create_with_grant = true
    usage_with_grant  = true
    role              = "cypress_app"
  }
  depends_on = [postgresql_role.list_of_roles]
}

resource "postgresql_role" "list_of_roles" {
  for_each   = toset(var.list_of_roles)
  provider   = postgresql.pgconnect
  name       = each.key
  depends_on = [aws_db_instance.postgres_rds]
}

resource "postgresql_grant" "readonly_tables" {
  for_each    = toset(["readonly_role"])
  provider    = postgresql.pgconnect
  database    = "postgres"
  role        = each.key
  schema      = postgresql_schema.my_schema.name
  object_type = "table"
  privileges  = ["SELECT"]
  depends_on  = [postgresql_role.list_of_roles]
}

resource "postgresql_grant" "readwrite_tables" {
  for_each    = toset(["readwrite_role"])
  provider    = postgresql.pgconnect
  database    = "postgres"
  role        = each.key
  schema      = postgresql_schema.my_schema.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on  = [postgresql_role.list_of_roles]
}

resource "postgresql_default_privileges" "read_only_tables" {
  for_each    = toset(["readonly_role"])
  provider    = postgresql.pgconnect
  role        = each.key
  database    = "postgres"
  schema      = postgresql_schema.my_schema.name
  owner       = postgresql_schema.my_schema.owner
  object_type = "table"
  privileges  = ["SELECT"]
  depends_on  = [postgresql_role.list_of_roles]
}

resource "postgresql_default_privileges" "readwrite_tables" {
  for_each    = toset(["readwrite_role"])
  provider    = postgresql.pgconnect
  role        = each.key
  database    = "postgres"
  schema      = postgresql_schema.my_schema.name
  owner       = postgresql_schema.my_schema.owner
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on  = [postgresql_role.list_of_roles]
}
