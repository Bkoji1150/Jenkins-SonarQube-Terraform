# hqr-operational-enviroment 

Using terraform to create and manage terraform

This module builds the infrastructure for **hqr-operational-enviroment** agen in the **REPORTING-BACKEND** cell.

This module was built using [Jenkins-SonarQube-Terraform](git@github.com:Bkoji1150/Jenkins-SonarQube-Terraform.git).

## Usage 
```hcl

module "microservice" {
  source = "git::git@github.com:Bkoji1150/hqr-operational-enviroment.git//ecs" # git::git@github.com:Bkoji1150/hqr-operational-enviroment.git//

  vpc_id           = local.vpc_id
  tier             = var.service_tier
  ecs_service_name = lower(format("%s-%s", var.cell_name, var.component_name))
  container_name   = var.container_name
  component_name   = var.component_name
  container_port   = var.container_port

  create_target_group           = false
  target_group_arn              = aws_lb_target_group.api.arn
  lb_listener_paths             = [var.target_group_health_check_path]
  lb_listener_arn               = aws_lb_listener.api.arn
  task_definition_task_role_arn = aws_iam_role.app_iam_role.arn

  ecs_service_subnet_ids    = local.private_subnets
  ecs_service_sg_ids        = [aws_security_group.ecs.id]
  ecs_service_desired_count = var.ecs_service_desired_count

  container_port_mappings = [{
    containerPort = var.container_port
    hostPort      = var.container_port
    protocol      = "tcp"
  }]

  container_log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-create-group"  = "true"
      "awslogs-group"         = var.component_name
      "awslogs-region"        = var.aws_region
      "awslogs-stream-prefix" = "ecs-api"
    }
    secretOptions = null
  }
  container_environment_variables = [
    {
      name  = "DJANGO_SECRET_KEY"
      value = var.django_secret_key
    },
    {
      name  = "DB_HOST"
      value = local.cluster_endpoint
    },
    {
      name  = "DB_NAME"
      value = local.cluster_database_name
    },
    {
      name  = "DB_USER"
      value = local.cluster_database_user
    },
    {
      name  = "DB_PASS"
      value = local.cluster_database_password
    },
    {
      name  = "ALLOWED_HOSTS"
      value = aws_route53_record.app.fqdn
    },
    {
      name  = "S3_STORAGE_BUCKET_NAME"
      value = aws_s3_bucket.app_public_files.bucket
    },
    {
      name  = "S3_STORAGE_BUCKET_REGION"
      value = data.aws_region.current.name
    }
  ]
  container_mount_points = [
    {
      readOnly      = false,
      containerPath = "/vol/web",
      sourceVolume  = "static"
    }
  ]
}

```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 3.0.0 |
| <a name="module_microservice"></a> [microservice](#module\_microservice) | ./ecs | n/a |
| <a name="module_required_tags"></a> [required\_tags](#module\_required\_tags) | git::https://github.com/Bkoji1150/kojitechs-tf-aws-required-tags.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ecs_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.app_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.api_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.app_public_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [template_file.ecs_s3_write_policy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [terraform_remote_state.operational_environment](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.recipe_db_cluster_secrets](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado"></a> [ado](#input\_ado) | HIDS ADO that owns the resource. The ServiceNow Contracts table is the system of record for the actual ADO names and LOB names. | `string` | `"Kojitechs"` | no |
| <a name="input_application"></a> [application](#input\_application) | Logical name for the application. Mainly used for kojitechs. For an ADO/LOB owned application default to the LOB name. | `string` | `"aws_eks"` | no |
| <a name="input_application_owner"></a> [application\_owner](#input\_application\_owner) | Email Address of the group who owns the application. This should be a distribution list and no an individual email if at all possible. Primarily used for Ventech-owned applications to indicate what group/department is responsible for the application using this resource. For an ADO/LOB owned application default to the LOB name. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Environment this template would be deployed to | `map(string)` | `{}` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"us-east-1"` | no |
| <a name="input_builder"></a> [builder](#input\_builder) | The name of the person who created the resource. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_cell_name"></a> [cell\_name](#input\_cell\_name) | The name of the cell. | `string` | `"TECH-GLOBAL"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster to deploy the service into. | `string` | `"recipe-api"` | no |
| <a name="input_component_name"></a> [component\_name](#input\_component\_name) | Name of the component. | `string` | `"api-recipe"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | n/a | `string` | `"recipe-app-api-devops"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port that this service will listen on. | `number` | `"9000"` | no |
| <a name="input_django_secret_key"></a> [django\_secret\_key](#input\_django\_secret\_key) | Secret key for Django app | `any` | n/a | yes |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Domain name | `any` | n/a | yes |
| <a name="input_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#input\_ecs\_service\_desired\_count) | Number of tasks to launch in the ECS service. | `number` | `1` | no |
| <a name="input_line_of_business"></a> [line\_of\_business](#input\_line\_of\_business) | HIDS LOB that owns the resource. | `string` | `"TECH"` | no |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Tier to deploy the service into. APP, WEB, or DATA | `string` | `"WEB"` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | Subdomain per environment | `map(string)` | <pre>{<br>  "prod": "api.prod",<br>  "sbx": "api.sbx",<br>  "shared": "api.shared"<br>}</pre> | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | n/a | `list(any)` | n/a | yes |
| <a name="input_target_group_health_check_path"></a> [target\_group\_health\_check\_path](#input\_target\_group\_health\_check\_path) | Path that will be used to perform the health check of the ECS service. | `string` | `"/admin/login/"` | no |
| <a name="input_tech_poc_primary"></a> [tech\_poc\_primary](#input\_tech\_poc\_primary) | Email Address of the Primary Technical Contact for the AWS resource. | `string` | `"kojitechs@gmail.com"` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Network tier or layer where the resource resides. These tiers are represented in every VPC regardless of single-tenant or multi-tenant. For most resources in the Infrastructure and Security VPC, the TIER will be Management. But in some cases,such as Atlassian, the other tiers are relevant. | `string` | `"APP"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The VPC the resource resides in. We need this to differentiate from Lifecycle Environment due to INFRA and SEC. One of "APP", "INFRA", "SEC", "ROUTING". | `string` | `"APP"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [kOJI BELLO](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-autoscaling/graphs/contributors).
