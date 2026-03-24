output "name" {
  value       = aws_autoscaling_group.main.name
  description = "ASG name"
}

output "id" {
  value       = aws_autoscaling_group.main.id
  description = "ASG ID"
}

output "arn" {
  value       = aws_autoscaling_group.main.arn
  description = "ASG ARN"
}
