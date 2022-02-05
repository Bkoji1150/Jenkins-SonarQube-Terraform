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


resource "postgresql_schema" "my_schema" {

  provider = postgresql.pgconnect
  count    = length(var.schemas_created)
  name     = var.schemas_created[count.index]
  owner    = "cypress_app"
}
/*
esource "postgresql_schema" "all_schemas" {
  
   for_each = {
    for idx, schema in var.schema_object: idx => schema
    if contains(var.db_users, schema.name)
  }  

  provider = postgresql.pgconnect
  count    = length(var.schemas_created)
  name     = var.schemas_created[count.index]
  owner    = "cypress_app"

  policy {
    usage = true
    role  = "${postgresql_role.app_www.name}"
  }


  policy {
    create = true
    usage  = true
    role   = "${postgresql_role.app_releng.name}"
  }

  policy {
    create_with_grant = true
    usage_with_grant  = true
    role              = "${postgresql_role.app_dba.name}"
  }
}
*/
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
