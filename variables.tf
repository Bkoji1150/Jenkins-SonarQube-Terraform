variable "public-subnet-count" {
  type    = number
  default = 3
}

variable "private-subnet-count" {
  type    = number
  default = 2
}

variable "fleur-cidr-block" {
  type    = string
  default = "150.0.0.0/16"
}

variable "map-public-ip" {
  type    = bool
  default = true
}


variable "instance-type" {
  type    = string
  default = "t2.medium"
}

variable "keypair" {
  type    = string
  default = "jenkins-sonar"
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
  default = "10.6"
}
variable "instance_class" {
  type    = string
  default = "db.m4.large"
}

variable "databases_created" {
  description = "List of all databases Created!!!"
  type        = list(any)
  default     = ["my_db1", "cypress_test"]
}

variable "username_taneble" {
  type    = list(any)
  default = ["app1", "app2"]
}
variable "db_subnet_group" {
  type    = bool
  default = true
}

variable "identifier" {
  type    = string
  default = "fleur_dbinstance"
}
variable "skip_db_snapshot" {
  type    = string
  default = true
}
variable "multi_az" {
  type    = bool
  default = true
}

variable "db_users" {
  type    = list(any)
  default = ["lots", "sprintbot", "cypress_user"]
}

variable "db_users_privileges" {
  #        description = <<<EOF
  #        {
  #          Example usage of db_users
  #        If user in this map does not exist in the db_users list, it would be ignored.
  #         db_users_privileges =
  #         {
  #           user = "example_user1"
  #           type = "example_type1"
  #           schema = "example_schema1"
  #           privileges = ["SELECT", "INSERT", "UPDATE","DELETE"]
  #        },
  #        {
  #           user = "example_user2"
  #           type = "example_type2"
  #           schema = "example_schema2"
  #           privileges = ["SELECT"]
  #        }
  #        ]
  #      Type options:
  #      database, schema, teble, sequence, function, foreign_data_wrapper, foreign_server
  #      Default values:
  #      type = "table"
  #      schema = "public"
  #      }
  #      EOF
  #
  type    = map(any)
  default = {}
}

variable "name_prefix" {
  description = ""
  type        = string
  default     = "lots"
}

variable "list_of_roles" {
  description = "List of roles in the database, like read/write"
  default     = ["readwrite_role", "readonly_role", "app_www", "test"]
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
    identifier = "postgres-sbx-dop"
  }
}

variable "account_role" {
  description = "Assume role"
  type        = string
  default     = "arn:aws:iam::735972722491:role/haplet-ec2-role"
}

variable "db_initial_id" {
  default = "Blesses#default"
}

variable "jenkins-tags" {
  type    = list(string)
  default = ["Master-node", "agen1"]
}

variable "public_key_path" {

}

variable "intanceec2" {
  default = "t3.micro"
}

variable "lambda_function_name" {
  default = "lambda_function_for_secrets_rotation"
}

variable "slack_url" {
  default = "https://hooks.slack.com/services/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"
}

variable "slack_channel" {
  default = "automation_channel"
}

variable "keypair_name" {
  default = "hapletkey"
}
