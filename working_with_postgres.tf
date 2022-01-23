provider "postgresql" {
  alias            = "pgconnect"
  host             = aws_db_instance.postgres_rds.address
  port             = aws_db_instance.postgres_rds.port
  username         = var.db_clusters.dbname
  password         = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  superuser        = false
  sslmode          = "require"
  expected_version = "10.6"
  connect_timeout  = 15
}

resource "postgresql_database" "postgres" {
  for_each          = toset(var.databases_created)
  provider          = postgresql.pgconnect
  name              = each.key
  allow_connections = true
}

provider "postgresql" {

  alias     = "pg2"
  host      = aws_db_instance.postgres_rds.address
  port      = aws_db_instance.postgres_rds.port
  username  = var.db_clusters.dbname
  superuser = false
  password  = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
}

resource "postgresql_role" "application_role" {
  for_each = toset(var.db_users) # Only for users that have password and are allowed to login
  name     = each.key
  login    = true
  provider = "postgresql.pg2"
}
resource "postgresql_schema" "my_schema" {
  name     = "cypress_schema"
  owner    = "app_www"
  provider = "postgresql.pg2"
  policy {
    usage = true
    role  = postgresql_role.app_www.name
  }

  # app_releng can create new objects in the schema.  This is the role that
  # migrations are executed as.
  policy {
    create = true
    usage  = true
    role   = postgresql_role.app_www.name
  }
  policy {
    create = true
    usage  = true
    role   = "test"
  }
  policy {
    create_with_grant = true
    usage_with_grant  = true
    role              = "cypress_app"
  }
}

resource "postgresql_role" "app_www" {
  provider = "postgresql.pg2"
  name     = "app_www"
}

resource "postgresql_role" "readonly_role" {
  provider = "postgresql.pg2"
  name     = "readonly_role"
}

resource "postgresql_role" "readwrite_role" {
  provider = "postgresql.pg2"
  name     = "readwrite_role"
}


resource "postgresql_grant" "readonly_tables" {
  for_each    = toset([postgresql_role.readonly_role.name])
  provider    = "postgresql.pg2"
  database    = "postgres"
  role        = each.key
  schema      = postgresql_schema.my_schema.name
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_grant" "readwrite_tables" {
  for_each    = toset([postgresql_role.readwrite_role.name])
  provider    = "postgresql.pg2"
  database    = "postgres"
  role        = each.key
  schema      = postgresql_schema.my_schema.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

#resource "postgresql_default_privileges" "read_only_tables" {
#  role = "test_role"
#database = "test_db"
#schema = "public"
#owner = "db_owner" object_type = "table"
#  privileges = ["SELECT"]
#}
/*
 resource "postgresql_grant" "users_prilages" {
     for_each = {
         for idx, user_privileges in var.db_users_privileges : idx => user_privileges
         if contains(var.db_users, user_privileges.user)
     }
   database    = var.db_clusters.bname
 #   role        = each.value.user
 #   schema      = each.value.privileges
    privileges  = ["SELECT"]
   role        = "test_role"
   schema      = "public"
   object_type = "table"
 #   objects     = ["table1", "table2"]
   depends_on = [
     postgresql_role.users
   ]
 }
*/
