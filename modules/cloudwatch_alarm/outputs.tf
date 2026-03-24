output "id" {
  value       = aws_cloudwatch_metric_alarm.alarm_metric.id
  description = "Alarm ID"
}

output "arn" {
  value       = aws_cloudwatch_metric_alarm.alarm_metric.arn
  description = "Alarm ARN"
}

output "name" {
  value       = aws_cloudwatch_metric_alarm.alarm_metric.alarm_name
  description = "Alarm name"
}