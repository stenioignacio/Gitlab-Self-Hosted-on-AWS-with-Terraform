output "user_name" {
  value       = aws_iam_user.service_user.name
  description = "IAM service user name"
}

output "user_arn" {
  value       = aws_iam_user.service_user.arn
  description = "IAM service user ARN"
}

output "user_credentials_name" {
  value       = module.secret.name
  description = "Secret Manager credentials name"
}

output "user_credentials_arn" {
  value       = module.secret.arn
  description = "Secret Manager credentials ARN"
}

output "user_credentials_id" {
  value       = module.secret.id
  description = "Secret Manager credentials ID"
}

output "user_access_key" {
  value       = aws_iam_access_key.key.id
  description = "IAM service user access key ID"
}

output "user_secret_key" {
  value       = aws_iam_access_key.key.secret
  description = "IAM service user secret access key"
}