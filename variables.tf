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
  default     = false
}

variable vol_size {
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

variable region {
  type    = string
  default = "us-east-2"
}

variable sonar_port {
  type    = number
  default = 9000
}

variable jenkins_port {
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
# variable "db_cluster" {
#   type = list
#   default = []
# }
# variable "username" {
#   type = string 
#   default = 
# }
# variable "password" {
#   type = string 
#   default = 
# }
variable "username_taneble" {
  type    = list
  default = ["app1", "app2"]
}
variable "db_subnet_group" {
  type    = bool
  default = true
}
# variable "vpc_security_group_ids" {
#   default = 
# }
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
  default = ["appli_role"]
}

variable db_users_privileges {
  #    description = "EOT 
  #    Example usage of db_users
  #    If user in this map does not exist in the db_users list, it would be ignored. 
  #     db_users_privileges = 
  #     {
  #       user = "example_user1"
  #       type = "example_type1"
  #       schema = "example_schema1"
  #       privileges = ["SELECT", "INSERT", "UPDATE","DELETE"]
  #    },
  #    {
  #       user = "example_user2"
  #       type = "example_type2"
  #       schema = "example_schema2"
  #       privileges = ["SELECT"]
  #    }
  #    ]
  #  Type options: 
  #  database, schema, teble, sequence, function, foreign_data_wrapper, foreign_server```
  #  Default values:
  #  ```type = "table"
  #  schema = "public"
  #  }
  #  EOT"
  type    = map(any)
  default = {}
}

variable "tenable_user" {
  default = "postgres_aa2"
}

variable "db_user_password" {
  default = ""
}

variable "db_clusters" {
  type        = map
  description = "The AWS DB cluster reference"
  default = {
    engine     = "postgres"
    name       = "kojips"
    port       = 5432
    dbname     = "kojiuser"
    identifier = "postg"
  }
}

variable "account_role" {
  description = "Assume role"
  type        = string
  default     = "arn:aws:iam::735972722491:role/haplet-ec2-role"

}

variable "db_initial_id" {
  default = "hshsye"
}

variable "jenkins-tags" {
  type    = list(string)
  default = ["Master-node", "agen1"]
}
