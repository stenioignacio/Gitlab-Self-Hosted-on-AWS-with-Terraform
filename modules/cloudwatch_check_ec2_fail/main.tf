resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  alarm_name          = format("status-check-failed-%s", var.instance_name)
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  alarm_description   = "Reboot EC2 if system status check fails"
  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [
    "arn:aws:automate:${var.region}:ec2:reboot",
    var.sns_topic_arn
  ]
}
