output "key_id" {
  value       = aws_kms_key.main.id
  description = "KMS key ID"
}

output "key_arn" {
  value       = aws_kms_key.main.arn
  description = "KMS key ARN"
}

output "alias_id" {
  value       = aws_kms_alias.main.id
  description = "KMS alias ID"
}

output "alias_arn" {
  value       = aws_kms_alias.main.arn
  description = "KMS alias ARN"
}
