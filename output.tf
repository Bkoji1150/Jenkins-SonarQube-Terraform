
output "ec2s-ippr" {
  value       = { for i in aws_instance.jenkinsinstance[*] : i.tags.Name => format("http://%s:%s", i.public_ip, var.jenkins_port) }
  description = "Public ippr addresses of jenkins nodes"
}

output "This_IS_Jenkins_Agen_private_ipprs" {
  value       = { for i in aws_instance.jenkinsinstance[*] : i.tags.Name => i.private_ip }
  description = "Private ippr addresses of jenkins nodes"
}
output "sonarqube" {
  value       = format("http://%s:%s", aws_instance.SonarQubesinstance.public_ip, var.sonar_port)
  description = "Sonarqube Public ip"
}
output "db_passwd" {
  sensitive = true
  value     = aws_db_instance.postgres_rds.password
}

output "secret_string" {
  value     = aws_secretsmanager_secret_version.master_secret_value.secret_string
  sensitive = true
}