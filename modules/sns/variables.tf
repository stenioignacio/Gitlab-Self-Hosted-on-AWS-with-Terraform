variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "name" {
  type        = string
  description = "SNS topic Name"
}

variable "protocol" {
  type        = string
  description = "Protocol type to use for the SNS topic"
}

variable "endpoint" {
  type        = list(string)
  description = "List of endpoints to subscribe to the SNS topic"
}