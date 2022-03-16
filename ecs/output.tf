
output "target_group_arn" {
  value = concat(aws_lb_target_group.target_group.*.arn, [""])[0]
}
