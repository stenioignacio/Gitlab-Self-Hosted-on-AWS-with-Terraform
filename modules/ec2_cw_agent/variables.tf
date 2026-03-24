variable "target_tag" {
  type        = string
  description = "Target tag for CloudWatch Agent"
}

variable "target_values" {
  type        = list(string)
  description = "Target tag values for CloudWatch Agent"
}

variable "action" {
  type        = string
  description = "Action type for EC2"
  default     = "Install"
}

variable "package_name" {
  type        = string
  description = "Package name to run on EC2"
  default     = "AmazonCloudWatchAgent"
}

variable "package_version" {
  type        = string
  description = "Package version to run on EC2"
  default     = "latest"
}

variable "instance_name" {
  type        = string
  description = "EC2 instance name"
}