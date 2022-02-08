variable "public-subnet" {
  type    = list(any)
  default = ["hqr-fronend-sub1", "hqr-fronend-sub2", "hqr-fronend-sub3", "hqr-fronend-sub4"]
}

variable "private-subnet" {
  type    = list(any)
  default = ["hqr-backend-sub1", "hqr-backend-sub2", "hqr-backend-sub3", "hqr-backend-sub4"]
}

variable "fleur-cidr-block" {
  type    = string
  default = "150.0.0.0/16"
}

variable "map-public-ip" {
  type    = bool
  default = true
}

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "vol_size" {
  type    = number
  default = 50
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_classiclink" {
  description = "Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "enable_classiclink_dns_support" {
  description = "Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "sonar_port" {
  type    = number
  default = 9000
}

variable "jenkins_port" {
  type    = number
  default = 8080
}

variable "db_storage" {
  type    = string
  default = 300
}

variable "engine_version" {
  description = "Hqr postgres db version"
  default     = "10.6"
}
variable "instance_class" {
  description = "hqr db instance class"
  type        = string
  default     = "db.m4.large"
}

variable "databases_created" {
  description = "List of all databases Created!!!"
  type        = list(string)
  default     = ["my_db1", "cypress_test"]
}

variable "db_subnet_group" {
  description = "hqr db subnet group"
  type        = bool
  default     = true
}

variable "identifier" {
  description = "hqr database identifier"
  type        = string
  default     = "fleur_dbinstance"
}
variable "skip_db_snapshot" {
  description = "skip snaption for hqr db instance"
  type        = string
  default     = true
}
variable "multi_az" {
  description = "Enable multity az for hqr db instance"
  type        = bool
  default     = true
}

variable "db_users" {
  description = "List of all databases"
  type        = list(any)
  default     = []
}

variable "db_users_privileges" {
  description = <<-EOT
  If a user in this map does not also exist in the db_users list, it will be ignored.
  Example usage of db_users:
  ```db_users_privileges = [
    {
      database  = "EXAMPLE POSTGRES"
      user       = “example_user1"
      type  = “example_type1”
      schema     = "example_schema1"
      privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
      objects    = [“example_object”]
    },
    {
      database  = "EXAMPLE POSTGRES"
      user       = “example_user2"
      type       = “example_type2”
      schema     = “example_schema2"
      privileges = [“SELECT”]
      objects    = []
    }
  ]```
  Note: An empty objects list applies the privilege on all database objects matching the type provided.
  For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html
  EOT
  type = list(object({
    user       = string
    type       = string
    schema     = string
    privileges = list(string)
    objects    = list(string)
    database   = string
  }))
  default = []
}

variable "schemas_list_owners" {
  description = <<-EOT
  If a schemas in this map does not also exist in the onwers list, it will be ignored.
  Example usage of schemas:
  ```schemas = [
    {
      database   = "postgres"
      name_of_theschema = "EXAMPLE_PUBLIC"
      onwer = "EXAMPLE_POSTGRES"
      policy {
        usage = true/false # yes to grant usage on schema
        role = "ROLE/USER" # The role/user to which this schema would be granted access to
      }
        # app_releng can create new objects in the schema.  This is the role that
         # migrations are executed as.
      policy {
      with_create_object = true/false
      with_usage = true/false
      role_name  = "postgres" if false null
  }
      ]```
  Note: An empty objects list applies the privilege on all database objects matching the type provided.
  For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html
  EOT
  type = list(object({
    database           = string
    name_of_theschema  = string
    onwer              = string
    usage              = bool
    role               = string
    with_create_object = bool
    with_usage         = bool
    role_name          = string
  }))
}

variable "name_prefix" {
  description = "Name prefix for secrets rotaion"
  type        = string
  default     = "hqr-database-reporting"
}

variable "tenable_user" {
  description = "RDS Teneble users"
  type        = string
  default     = "postgres_aa2"
}

variable "count_jenkins_agents" {
  type    = number
  default = 2
}

variable "db_clusters" {
  type        = map(any)
  description = "The AWS DB cluster reference"
  default = {
    engine     = "postgres"
    name       = "cypress_app"
    port       = 5432
    dbname     = "cypress_app"
    identifier = "hqr-database-reporting"
  }
}

variable "db_initial_id" {
  type        = string
  description = "database initail id"
  default     = "Blesses#default"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the lambda function"
  default     = "lambda_function_for_secrets_rotation"
}

variable "slack_url" {
  type        = string
  description = "url of slack"
  sensitive   = true
  default     = "https://hooks.slack.com/services/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"
}

variable "slack_channel" {
  description = "Slack channel name"
  type        = string
  default     = "automation_channel"
}

variable "typ" {
  description = "type"
  type        = bool
  default     = true
}