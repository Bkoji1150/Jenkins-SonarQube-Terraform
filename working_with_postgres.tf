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

# (contains(var.databases_created, each.value.database)? each.value.database : "postgres"
resource "postgresql_schema" "my_schema" {
  for_each = {
    for schema, value in var.schemas_list_owners : schema => value
  }
  # Beware schema is a database object and not cluster object like users
  # Meaning the database you selected would dertermind were the schema would be created
  provider = postgresql.pgconnect
  name     = each.value.onwer == "database" || each.value.database == "schema" ? null : each.value.name_of_theschema
  owner    = each.value.onwer
  database = contains(var.databases_created, each.value.database) ? each.value.database : "postgres"
  policy {
    usage = each.value.usage
    role  = each.value.role
  }

  # app_releng can create new objects in the schema.  This is the role that
  # migrations are executed as.
  # This is most likely only for admin users
  policy {
    create = each.value.with_create_object
    usage  = each.value.with_usage
    role   = each.value.role_name
  }
  depends_on = [aws_db_instance.postgres_rds]
}

resource "postgresql_role" "users" {
  provider   = postgresql.pgconnect
  for_each   = toset(var.db_users)
  name       = each.key
  login      = true
  password   = random_password.users_password[each.key].result
  depends_on = [aws_db_instance.postgres_rds]
}

resource "postgresql_grant" "user_privileges" {
  for_each = {
    for idx, user_privileges in var.db_users_privileges : idx => user_privileges
    if contains(var.db_users, user_privileges.user)
  }

  database    = each.value.database
  provider    = postgresql.pgconnect
  role        = each.value.user
  privileges  = each.value.privileges
  object_type = each.value.type
  schema      = each.value.type == "database" && each.value.schema == "" ? null : each.value.schema
  objects     = each.value.type == "database" || each.value.type == "schema" ? null : each.value.objects
  depends_on  = [postgresql_role.users]
}