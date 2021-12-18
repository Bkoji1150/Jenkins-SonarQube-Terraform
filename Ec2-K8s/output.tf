output "instance" {
  value     = { for i in aws_instance.project-omega : i.tags.Name => i.private_ip }
  sensitive = false
}

#  output "resource_arn" {
#   value = aws_instance.project-omega.arn

#  }