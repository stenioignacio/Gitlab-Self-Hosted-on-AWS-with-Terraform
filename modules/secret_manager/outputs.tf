output "name" {
  value       = aws_secretsmanager_secret.secret.name
  description = "Secret name"
}

output "arn" {
  value       = aws_secretsmanager_secret.secret.arn
  description = "Secret ARN"
}

output "id" {
  value       = aws_secretsmanager_secret.secret.id
  description = "Secret ID"
}