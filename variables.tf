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

variable "jenkins-tags" {
  type    = list(string)
  default = ["jenkins-agen1", "jenkins-agen2"]
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
