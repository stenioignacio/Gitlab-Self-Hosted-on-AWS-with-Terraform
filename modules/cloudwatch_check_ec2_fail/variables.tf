variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

#IAM
variable "action" {
  type        = list(string)
  description = "IAM permission actions"
  default     = ["ec2:RebootInstances"]
}

# Cloudwatch
variable "comparison_operator" {
  type        = string
  description = "Comparison operator"
  default     = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  type        = number
  description = "Number of evaluation periods"
  default     = 2
}

variable "threshold" {
  type        = number
  description = "Number of consecutive failures before reboot"
  default     = 2
}

variable "metric_name" {
  type        = string
  description = "Metric name"
  default     = "StatusCheckFailed"
}

variable "namespace" {
  type        = string
  description = "Namespace da metrica Cloudwatch"
  default     = "AWS/EC2"
}

variable "period" {
  type        = number
  description = "Time period between checks (seconds)"
  default     = 60
}

variable "statistic" {
  type        = string
  description = "Statistic used"
  default     = "Maximum"
}

variable "instance_name" {
  type        = string
  description = "EC2 instance name to reboot"
}

variable "instance_id" {
  type        = string
  description = "EC2 instance ID to reboot"
}

variable "region" {
  type        = string
  description = "EC2 region"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN"
}