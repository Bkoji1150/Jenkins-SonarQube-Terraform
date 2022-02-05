db_users = [
  "kojibello",
  "kelder"
]

db_users_privileges = [
  {
    objects    = []
    privileges = ["SELECT"]
    schema     = "public"
    type       = "table"
    user       = "kojibello"
  },
  {
    objects    = []
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "public"
    type       = "table"
    user       = "kelder"
  }
]

schemas_created = ["monolic", "cypress_schema"]
