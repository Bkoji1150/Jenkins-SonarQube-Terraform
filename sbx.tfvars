db_users = [
  "kojibello",
  "kelder",
  "apple",
  "pop"
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
  }
]

schemas_created = ["monolic", "cypress_schema"]
