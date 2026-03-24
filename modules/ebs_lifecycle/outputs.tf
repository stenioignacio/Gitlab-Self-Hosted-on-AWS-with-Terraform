output "id" {
  value       = aws_dlm_lifecycle_policy.main.id
  description = "Lifecycle policy ID"
}

output "arn" {
  value       = aws_dlm_lifecycle_policy.main.arn
  description = "Lifecycle policy ARN"
}