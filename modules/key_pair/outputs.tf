output "name" {
  description = "The name of the key pair"
  value       = aws_key_pair.main.key_name
}

output "arn" {
  value       = aws_key_pair.main.arn
  description = "Key Pair ARN"
}

output "id" {
  value       = aws_key_pair.main.id
  description = "Key Pair ID"
}