output "id" {
  value       = aws_lb_target_group.main.id
  description = "Target group ID"
}

output "name" {
  value       = aws_lb_target_group.main.name_prefix
  description = "Target group name"
}

output "arn" {
  value       = aws_lb_target_group.main.arn
  description = "Target group ARN"
}