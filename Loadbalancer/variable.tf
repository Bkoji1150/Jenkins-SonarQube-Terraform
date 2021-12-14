variable "db_subnet_group_name" {
  type = bool 
  default = true
  }
variable "public_sg" {}
variable "public_subnets" {}
variable "tg_port" {}
variable "tg_portocol" {}
variable "Project-Omega_healthy_threshold" {}
variable "Project-Omega_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "vpc_id" {}
variable "listener_port" {}
variable "listener_protocol" {}