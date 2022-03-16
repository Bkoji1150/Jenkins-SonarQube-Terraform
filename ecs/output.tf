
output "target_group_arn" {
  value = concat(aws_lb_target_group.target_group.*.arn, [""])[0]
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_service.ecs_service.name
}
