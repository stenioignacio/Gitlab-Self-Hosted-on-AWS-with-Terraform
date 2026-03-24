output "id" {
  value       = aws_cloudwatch_metric_alarm.ec2_status_check_failed.id
  description = "Alarm ID that reboots the EC2 instance"
}

output "arn" {
  value       = aws_cloudwatch_metric_alarm.ec2_status_check_failed.arn
  description = "Alarm ARN that reboots the EC2 instance"
}

output "name" {
  value       = aws_cloudwatch_metric_alarm.ec2_status_check_failed.alarm_name
  description = "Alarm name for the EC2 reboot alarm"
}