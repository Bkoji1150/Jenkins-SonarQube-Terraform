variable "aws_region" {
  description = "AWS Region."
  type        = string
  default     = "us-east-1"
}

variable "service_name" {
  description = "Name of the service."
  type        = string
  default     = "reporting"
}

variable "cell_name" {
  description = "Name of the cell."
  type        = string
  default     = "reporting-frontend"
}

variable "component_name" {
  description = "Name of the component."
  type        = string
  default     = "reports-ui-microservice"
}

variable "service_tier" {
  description = "Tier to deploy the service into. APP, WEB, or DATA"
  type        = string
  default     = "WEB"
}

# Required Tags variables
variable "application_owner" {
  description = "Email Group for the Application owner."
  type        = string
  default     = "hqr-feedback-and-support-product@bellese.io"
}

variable "builder" {
  description = "Email for the builder of this infrastructure"
  type        = string
  default     = "hqr-devops@bellese.io"
}

variable "tech_poc_primary" {
  description = "Primary Point of Contact for Technical support for this service."
  type        = string
  default     = "hqr-feedback-and-support-product@bellese.io"
}

variable "tech_poc_secondary" {
  description = "Secondary Point of Contact for Technical support for this service."
  type        = string
  default     = "hqr-devops@bellese.io"
}

# Service Configuration
variable "container_port" {
  description = "Port that this service will listen on."
  type        = number
  default     = "80"
}

variable "ecs_service_desired_count" {
  description = "Number of tasks to launch in the ECS service."
  type        = number
  default     = 1
}

variable "lb_listener_path" {
  description = "Path that will be used to route traffic from the load balancer to the ECS service."
  type        = string
  default     = "/index.html/*"
}

variable "target_group_health_check_path" {
  description = "Path that will be used to perform the health check of the ECS service."
  type        = string
  default     = "/index.html/*"
}

variable "container_image_source" {
  description = "Where to fetch the container image. ecr or dockerhub"
  type        = string
  default     = "ecr"
}

variable "container_image_version" {
  description = "Version of the container image to deploy."
  type        = string
}


# Container Environment Variables
