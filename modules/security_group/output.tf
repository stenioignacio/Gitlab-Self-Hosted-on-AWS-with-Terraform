output "security_group_id" {
  value       = aws_security_group.main.id
  description = "Security Group ID"
}

output "name" {
  value       = aws_security_group.main.name
  description = "Security Group name"
}