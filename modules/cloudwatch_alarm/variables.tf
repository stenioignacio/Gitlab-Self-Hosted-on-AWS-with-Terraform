variable "name" {
  type        = string
  description = "CloudWatch alarm name"
}

variable "comparison_operator" {
  type        = string
  description = "Comparison operator"
}

variable "evaluation_periods" {
  type        = number
  description = "Number of evaluation periods to compare desired vs current resource state"
}

variable "metric_name" {
  type        = string
  description = "Metric name"
}

variable "namespace" {
  type        = string
  description = "CloudWatch metric namespace"
}

variable "threshold" {
  type        = number
  description = "Number of consecutive failures before EC2 is restarted"
  default     = 2
}

variable "period" {
  type        = number
  description = "Time period between checks (seconds)"
}

variable "statistic" {
  type        = string
  description = "Statistic used"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN"
}

variable "dimension" {
  type = map(string)
}

variable "alarm_description" {
  type        = string
  description = "Alarm description"
}

variable "datapoints_to_alarm" {
  type        = number
  description = "Number of data points to alarm"
  default     = 1
}  