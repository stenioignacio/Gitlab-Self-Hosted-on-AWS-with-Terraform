output "host" {
  value       = aws_db_instance.main.address
  description = "RDS host for connection"
}

output "availability_zone" {
  value       = aws_db_instance.main.availability_zone
  description = "RDS availability zone"
}

output "port" {
  value       = aws_db_instance.main.port
  description = "Database port"
}

output "user" {
  value       = aws_db_instance.main.username
  description = "RDS default username"
}

output "password" {
  value       = aws_db_instance.main.password
  description = "RDS default password"
}

output "database" {
  value       = aws_db_instance.main.db_name
  description = "Database name"
}