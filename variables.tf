
variable "aws_region" {
  description = "AWS Region."
  type        = string
  default     = "us-east-1"
}

variable "component_name" {
  description = "Name of the component."
  type        = string
  default     = "api-recipe"
}

variable "container_name" {
  description = ""
  type        = string
  default     = "recipe-app-api-devops"
}

variable "service_tier" {
  description = "Tier to deploy the service into. APP, WEB, or DATA"
  type        = string
  default     = "WEB"
}

# Service Configuration
variable "container_port" {
  description = "Port that this service will listen on."
  type        = number
  default     = "9000"
}

variable "ecs_service_desired_count" {
  description = "Number of tasks to launch in the ECS service."
  type        = number
  default     = 1
}

variable "target_group_health_check_path" {
  description = "Path that will be used to perform the health check of the ECS service."
  type        = string
  default     = "/admin/login/"
}

variable "dns_zone_name" {
  description = "Domain name"
}

variable "subdomain" {
  description = "Subdomain per environment"
  type        = map(string)
  default = {
    prod   = "api.prod"
    sbx    = "api.sbx"
    shared = "api.shared"
  }
}

###### 
variable "aws_account_id" {
  description = "Environment this template would be deployed to"
  type        = map(string)
  default     = {}
}

variable "line_of_business" {
  description = "HIDS LOB that owns the resource."
  type        = string
  default     = "TECH"
}

variable "ado" {
  description = "HIDS ADO that owns the resource. The ServiceNow Contracts table is the system of record for the actual ADO names and LOB names."
  type        = string
  default     = "Kojitechs"
}

variable "tier" {
  description = "Network tier or layer where the resource resides. These tiers are represented in every VPC regardless of single-tenant or multi-tenant. For most resources in the Infrastructure and Security VPC, the TIER will be Management. But in some cases,such as Atlassian, the other tiers are relevant."
  type        = string
  default     = "APP"
}

variable "tech_poc_primary" {
  description = "Email Address of the Primary Technical Contact for the AWS resource."
  type        = string
  default     = "kojitechs@gmail.com"
}

variable "application" {
  description = "Logical name for the application. Mainly used for kojitechs. For an ADO/LOB owned application default to the LOB name."
  type        = string
  default     = "aws_eks"
}

variable "builder" {
  description = "The name of the person who created the resource."
  type        = string
  default     = "kojitechs@gmail.com"
}

variable "application_owner" {
  description = "Email Address of the group who owns the application. This should be a distribution list and no an individual email if at all possible. Primarily used for Ventech-owned applications to indicate what group/department is responsible for the application using this resource. For an ADO/LOB owned application default to the LOB name."
  default     = "kojitechs@gmail.com"
}

variable "vpc" {
  description = "The VPC the resource resides in. We need this to differentiate from Lifecycle Environment due to INFRA and SEC. One of \"APP\", \"INFRA\", \"SEC\", \"ROUTING\"."
  type        = string
  default     = "APP"
}

variable "cell_name" {
  description = "The name of the cell."
  type        = string
  default     = "TECH-GLOBAL"
}

variable "django_secret_key" {
  description = "Secret key for Django app"
}

variable "subject_alternative_names" {
  type = list(any)
}

variable "cluster_name" {
  description = "Name of the ECS cluster to deploy the service into."
  type        = string
  default     = "recipe-api"
}
