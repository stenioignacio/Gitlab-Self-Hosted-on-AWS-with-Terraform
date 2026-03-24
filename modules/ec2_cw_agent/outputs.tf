output "name" {
  value       = aws_ssm_association.install_cw_agent.name
  description = "Name of the Run Command in Systems Manager"
}

output "id" {
  value       = aws_ssm_association.install_cw_agent.id
  description = "Run Command ID in Systems Manager"
}

output "arn" {
  value       = aws_ssm_association.install_cw_agent.arn
  description = "Run Command ARN in Systems Manager"
}