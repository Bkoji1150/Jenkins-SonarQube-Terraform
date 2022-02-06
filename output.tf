output "db_passwd" {
  sensitive = true
  value     = aws_db_instance.postgres_rds.password
}

output "secret_string" {
  value     = aws_secretsmanager_secret_version.master_secret_value.secret_string
  sensitive = true
}

output "lambda" {
  value = aws_lambda_function.test_lambda.qualified_arn
}

output "vpc_id" {
  value = aws_vpc.fleur-vpc[0].id
}

output "frontend_subnet_ids" {
  description = "List of all frontend ids"
  value       = [for idx in aws_subnet.fleur-public-subnet : idx.id]
}

output "backend_subnet_ids" {
  description = "List of all frontend ids"
  value       = [for idx in aws_subnet.fleur-private-subnet : idx.id]
}
