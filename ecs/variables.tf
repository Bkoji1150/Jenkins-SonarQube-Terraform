variable "vpc_id" {
  description = "ID of the VPC that corresponds with the operational environment."
  type        = string
}

variable "tier" {
  description = "Canonical name of the application tier."
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster to deploy the service into."
  type        = string
  default     = null
}

variable "name" {}

variable "cfqn_name" {
  description = "Cell Fully Qualified Name. Will be used to name the ECS Service, Target Group, Task Definition and Container."
  type        = string
}

variable "component_name" {
  description = ""
  type        = string
}

variable "container_name" {
  description = ""
  type        = string
}

variable "container_image" {
  type        = string
  description = "The image used to start a container. Up to 255 letters (uppercase and lowercase), numbers, hyphens, underscores, colons, periods, forward slashes, and number signs are allowed."
  default     = null
}
variable "assign_public_ip" {
  type        = bool
  description = "Would you like to allow public ip"
}
variable "ecr_account_id" {
  type        = string
  description = "The ID of the account to which the ECR repository belongs."
  default     = "735972722491"
}

variable "container_source" {
  default = "ecr"
}

#variable "tags" {
#  description = "Tags to apply to the IAM module resource."
#  type        = map(any)
#  validation {
#    condition     = length(var.tags) >= 9 && contains(keys(var.tags), “ado”) && contains(keys(var.tags), “cell-name”) && contains(keys(var.tags), “component-name”)
#    error_message = “Tags for this module must contain the minimum keys from the `bellese-tf-aws-required-tags`  module.”
#  }
#}
variable "container_version" {

}
variable "task_execution_role_name" {
  description = "Name of the IAM role to be used at the task execution role in the task definition"
  type        = string
  default     = null
}

# Container Definition variables
variable "container_launch_type" {
  description = "Either `EC2` or `FARGATE`"
  type        = string
  default     = "FARGATE"
}

variable "container_network_mode" {
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
  type        = string
  default     = "awsvpc"
}

variable "container_image_source" {
  description = "Either `dockerhub` or `ecr`."
  type        = string
}

variable "container_image_version" {
  description = "Version of the container image to deploy."
  type        = string

}

variable "container_cpu" {
  description = "Number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value."
  type        = number
  default     = 512
}

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  type        = number
  default     = 128
}

variable "task_memory" {
  description = "The hard limit of memory (in MiB) to present to the task."
  type        = number
  default     = 512
}

variable "task_cpu" {
  description = "The hard limit of CPU units to present for the task."
  type        = number
  default     = 256
}

variable "container_port_mappings" {
  description = "Port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort."
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
}

variable "essential" {
  description = "Determines whether all other containers in a task are stopped, if this container fails or stops for any reason. Due to how Terraform type casts booleans in json it is required to double quote this value."
  type        = bool
  default     = true
}

variable "container_command" {
  description = "A list of strings to run as the container command."
  type        = list(string)
  default     = []
}

variable "container_ulimits" {
  type = list(object({
    name      = string
    hardLimit = number
    softLimit = number
  }))
  description = "Container ulimit settings. This is a list of maps, where each map should contain \"name\", \"hardLimit\" and \"softLimit\""
  default     = null
}

variable "container_environment_variables" {
  description = "Environment variables to pass to the container. This is a list of maps."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets to fetch and pass to the container. This is a list of maps."
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "container_log_configuration" {
  description = "Log configuration options to send to a custom log driver for the container. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html."
  type = object({
    logDriver = string
    options   = map(string)
    secretOptions = list(object({
      name      = string
      valueFrom = string
    }))
  })
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html
variable "container_linux_parameters" {
  type = object({
    capabilities = object({
      add  = list(string)
      drop = list(string)
    })
    devices = list(object({
      containerPath = string
      hostPath      = string
      permissions   = list(string)
    }))
    initProcessEnabled = bool
    maxSwap            = number
    sharedMemorySize   = number
    swappiness         = number
    tmpfs = list(object({
      containerPath = string
      mountOptions  = list(string)
      size          = number
    }))
  })
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default     = null
}

variable "container_entrypoint" {
  description = "For details on this variable, see `entrypoint` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_working_directory" {
  description = "For details on this variable, see `working_directory` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_readonly_root_filesystem" {
  description = "For details on this variable, see `readonly_root_filesystem` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = bool
  default     = false
}

variable "container_dns_servers" {
  description = "For details on this variable, see `dns_servers` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_repository_credentials" {
  description = "For details on this variable, see `repository_credentials` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_links" {
  description = "For details on this variable, see `links` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_volumes_from" {
  description = "For details on this variable, see `volumes_from` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_user" {
  description = "For details on this variable, see `user` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_container_depends_on" {
  description = "For details on this variable, see `container_depends_on` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_privileged" {
  # description = “For details on this variable, see `privileged` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type    = any
  default = null
}

variable "container_healthcheck" {
  # description = “For details on this variable, see `healthcheck` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type    = any
  default = null
}

variable "container_firelens_configuration" {
  description = "For details on this variable, see `firelens_configuration` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_docker_labels" {
  description = "For details on this variable, see `docker_labels` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

variable "container_start_timeout" {
  description = "For details on this variable, see `start_timeout` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = number
  default     = 30
}

variable "container_stop_timeout" {
  description = "For details on this variable, see `stop_timeout` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = number
  default     = 30
}

variable "container_system_controls" {
  description = "For details on this variable, see `system_controls` variable in https://qnetgit.cms.gov/Bellese/hqr-tf-aws-container-definition"
  type        = any
  default     = null
}

# ECS Service variables
variable "create_target_group" {
  description = "Set to false if passing in a `target_group_arn`."
  type        = bool
  default     = true
}

variable "create_listener_rule" {
  description = "Set to false if built by site-nav-frontend and the target group will be set as the default in the operational environment"
  type        = bool
  default     = true
}

variable "target_group_stickiness" {
  description = "Stickiness configuration for the target group."
  type = object({
    type            = string
    cookie_duration = number
    enabled         = bool
  })
  default = null
}

variable "target_group_arn" {
  # description = “The ARN of a Target Group to use instead of creating. Must also set `create_target_group` to `false`."
  type    = string
  default = null
}

variable "lb_listener_paths" {
  # description = “List of Paths that will be used to route traffic from the load balancer to the ECS service."
  type    = list(string)
  default = null
}

variable "lb_listener_arn" {
  # description = “ARN of the listener on the load balancer that will route traffic to the ECS service."
  type    = string
  default = null
}

variable "ecs_service_desired_count" {
  description = "Number of tasks to launch in the ECS service."
  type        = number
}

variable "ecs_service_subnet_ids" {
  description = "List of IDs of the subnets where the ECS service will be created. Do not specify if using EC2 Launch Type"
  type        = list(string)
  default     = null
}

variable "ecs_service_sg_ids" {
  description = "List of security group IDs to be attached to the ECS service. Do not specify if using EC2 Launch Type"
  type        = list(string)
  default     = null
}

variable "target_group_protocol" {
  description = "Protocol of the traffic being sent on the ECS service."
  type        = string
  default     = "HTTP"
}

variable "target_group_load_balancing_algorithm_type" {
  description = "Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups. The value is `round_robin` or `least_outstanding_requests`. The default is `round_robin`."
  type        = string
  default     = "round_robin"
}

variable "target_group_deregistration_delay" {
  description = "Number of seconds to wait before removing a task from the target group."
  type        = number
  default     = 30
}
variable "target_group_healthy_threshold_count" {
  description = "Number of consecutive positive responses to the health check necessary for the target to be considered healthy."
  type        = number
  default     = 5
}

variable "target_group_unhealthy_threshold_count" {
  description = "Number of consecutive negative responses to the health check necessary for the target to be considered unhealthy."
  type        = number
  default     = 2
}

variable "target_group_health_check_path" {
  description = "Path that will be used to perform the health check of the ECS service."
  type        = string
  default     = null
}

variable "target_group_health_check_port" {
  description = "The port to use to connect with the target. Valid values are either ports 1-65535, or `traffic-port`. Defaults to `traffic-port`."
  type        = string
  default     = "traffic-port"
}

variable "target_group_health_check_matcher" {
  description = "(Required for HTTP/HTTPS ALB) The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`). Applies to Application Load Balancers only (HTTP/HTTPS), not Network Load Balancers (TCP)."
  type        = string
  default     = "200"
}

variable "target_group_health_check_interval" {
  description = "Number of seconds to wait between performing health checks on a target."
  type        = number
  default     = 60
}

variable "target_group_health_check_timeout" {
  description = "Number of seconds to wait for a response to the health check before the request times out."
  type        = number
  default     = 30
}

variable "target_group_health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647."
  type        = number
  default     = 60
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service’s desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service’s desiredCount) of the number of running tasks that can be running in a service during a deployment."
  type        = number
  default     = 200
}

variable "deployment_controller" {
  description = "Type of deployment controller. Valid values: `CODE_DEPLOY`, `ECS`, `EXTERNAL`."
  type        = string
  default     = "ECS"
}

variable "fargate_platform_version" {
  description = "The platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`."
  type        = string
  default     = "LATEST"
}

variable "container_volumes" {
  description = "The Volume property specifies a data volume used in a task definition. For tasks that use a Docker volume, specify a DockerVolumeConfiguration. For tasks that use a bind mount host volume, specify a host and optional sourcePath."
  default     = []
}

variable "container_mount_points" {
  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`"
  type = list(object({
    containerPath = string
    sourceVolume  = string
  }))
  default = null
}

# ECS Task Definition variables
variable "container_port" {
  description = "Port on which the container will listen for traffic."
  type        = number
}

variable "task_definition_task_role_arn" {
  description = "ARN of the IAM role used by the task definition."
  type        = string
  default     = null
}
