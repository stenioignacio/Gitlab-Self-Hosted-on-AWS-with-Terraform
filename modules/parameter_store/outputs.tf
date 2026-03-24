output "name" {
  value       = aws_ssm_parameter.main.name
  description = "Parameter name"
}

output "value" {
  value       = aws_ssm_parameter.main.value
  description = "Value stored in the parameter"
}