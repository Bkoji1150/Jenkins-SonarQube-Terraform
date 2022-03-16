db_users = [
  "kojibello",
  "kelder",
  "apple",
  "pop",
  "ange",
  "missif"
]

db_users_privileges = [
  {
    database   = "postgres"
    privileges = ["SELECT"]
    schema     = "public"
    type       = "table"
    user       = "kojibello"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "public"
    type       = "table"
    user       = "kelder"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "cypress_schema"
    type       = "table"
    user       = "kelder"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT"]
    schema     = "cypress_schema"
    type       = "table"
    user       = "apple"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["USAGE"]
    schema     = "cypress_schema"
    type       = "schema"
    user       = "apple"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "cypress_schema"
    type       = "table"
    user       = "apple"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "cypress_schema"
    type       = "table"
    user       = "pop"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["USAGE"]
    schema     = "cypress_schema"
    type       = "schema"
    user       = "pop"
    objects    = []
  }
]

schemas_list_owners = [

  {
    database           = "postgres"
    name_of_theschema  = "cypress_schema"
    onwer              = "cypress_app"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "cypress_app"
  },
  {
    database           = "my_db1"
    name_of_theschema  = "test"
    onwer              = "cypress_app"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "cypress_app"
  },
  {
    database           = "cypress_test"
    name_of_theschema  = "test1"
    onwer              = "apple"
    usage              = true
    role               = "cypress_app"
    with_create_object = true
    with_usage         = true
    role_name          = "cypress_app"
  }
]
