output "pub-subnets" {
  value       = aws_subnet.fleur-public-subnet[0].id
  description = "Pub subnet ids"
}

output "ec2s-ippr" {
  value       = { for i in aws_instance.jenkinsinstance[*] : i.tags.Name => format("http://%s:%s", i.public_ip, var.jenkins_port)}
  description = "Public ippr addresses of jenkins nodes"
}

output "This_IS_Jenkins_Agen_private_ipprs" {
  value       = { for i in aws_instance.jenkinsinstance[*] : i.tags.Name =>  i.private_ip }
  description = "Private ippr addresses of jenkins nodes"
}
output "sonarqube" {
  value       = format("http://%s:%s", aws_instance.SonarQubesinstance.public_ip, var.sonar_port)
  description = "Sonarqube Public ip"
}



