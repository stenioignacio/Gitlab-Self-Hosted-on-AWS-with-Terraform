output "arn" {
  value       = aws_sns_topic.main.arn
  description = "SNS topic ARN"
}

output "id" {
  value       = aws_sns_topic.main.id
  description = "SNS topic ID"
}

output "name" {
  value       = aws_sns_topic.main.name
  description = "SNS topic name"
}