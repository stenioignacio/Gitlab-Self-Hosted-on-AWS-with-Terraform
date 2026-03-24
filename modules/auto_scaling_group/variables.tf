variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "img_owner" {
  type        = list(string)
  description = "Image owner"
}

variable "image" {
  type        = list(string)
  description = "EC2 instance image name"
}

variable "instance_profile_permissions" {
  type        = list(string)
  description = "List of permissions for the EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "name" {
  type        = string
  description = "Auto Scaling Group name"
}

variable "user_data_script" {
  type        = string
  description = "Bash script for instance initialization"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs"
}

variable "spot_instance" {
  type        = bool
  description = "Enable spot instances"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity for the Auto Scaling Group"
}

variable "max_size" {
  type        = number
  description = "Auto Scaling Group maximum size"
}

variable "min_size" {
  type        = number
  description = "Auto Scaling Group minimum size"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets for the ASG instances"
}

#Warm pool variables
variable "warm_pool_activated" {
  type        = bool
  description = "Enable ASG warm pool (default: min 1 | max 10)"
  default     = false
}

variable "warm_pool_pool_state" {
  type        = string
  description = "Warm pool state"
  default     = ""
}

variable "warm_pool_min_size" {
  type        = number
  description = "Warm pool minimum size"
  default     = 0
}

variable "warm_pool_max_group_prepared_capacity" {
  type        = number
  description = "Maximum number of instances prepared in the warm pool"
  default     = 0
}

#Cloudwatch alarm
variable "comparison_operator" {
  type        = string
  description = "Comparison operator"
  default     = "GreaterThanOrEqualToThreshold"
}

variable "evaluation_periods" {
  type        = number
  description = "Evaluation periods"
  default     = 2
}

variable "metric_name" {
  type        = string
  description = "Metric name"
  default     = "GroupTotalInstances"
}

variable "namespace" {
  type        = string
  description = "Namespace"
  default     = "AWS/AutoScaling"
}

variable "period" {
  type        = number
  description = "Period"
  default     = 300
}

variable "statistic" {
  type        = string
  description = "Statistic"
  default     = "Average"
}

variable "threshold" {
  type        = list(number)
  description = "Threshold"
}

variable "alarm_description" {
  type        = string
  description = "Alarm description"
  default     = "Alarm limits ASG"
}

variable "datapoints_to_alarm" {
  type        = number
  description = "Data points to alarm"
  default     = 1
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN"
}

variable "tag_specifications_resource" {
  type        = list(string)
  description = "Tag specification for resources created by ASG EC2 instances"
  default = [
    "volume",
    "network-interface"
  ]
}