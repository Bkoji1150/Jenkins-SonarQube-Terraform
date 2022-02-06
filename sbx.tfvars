db_users = [
  "kojibello",
  "kelder",
  "apple",
  "pop",
  "ange"
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
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT"]
    schema     = "test"
    type       = "table"
    user       = "ange"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["USAGE"]
    schema     = "test"
    type       = "schema"
    user       = "ange"
    objects    = []
  }
]

schemas_created = ["monolic", "cypress_schema"]
