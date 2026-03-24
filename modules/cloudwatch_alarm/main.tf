resource "aws_cloudwatch_metric_alarm" "alarm_metric" {
  alarm_name          = var.name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  alarm_description   = var.alarm_description
  dimensions          = var.dimension
  datapoints_to_alarm = var.datapoints_to_alarm

  alarm_actions = [var.sns_topic_arn]
}
