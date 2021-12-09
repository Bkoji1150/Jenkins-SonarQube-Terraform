output "pub-subnets" {
  value       = aws_subnet.fleur-public-subnet[0].id
  description = "Pub subnet ids"
}

output "ec2s-ippr" {
  value       = aws_instance.jenkinsinstance.*.public_ip
  description = "IP addresses"
}

output "sonarqube" {
  value       = aws_instance.SonarQubesinstance.public_ip
  description = "Sonarqube Public ip"
}

