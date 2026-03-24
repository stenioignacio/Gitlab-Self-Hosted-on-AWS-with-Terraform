output "arn" {
  value       = aws_iam_role.role.arn
  description = "IAM role ARN"
}

output "id" {
  value       = aws_iam_role.role.id
  description = "IAM role ID"
}

output "name" {
  value       = aws_iam_role.role.name
  description = "IAM role name"
}