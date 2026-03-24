variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "protocol" {
  type        = string
  description = "Target Group protocol"
}

variable "port" {
  type        = number
  description = "Target Group port"
}

variable "target_id" {
  type        = string
  description = "Target ID"
}

variable "matcher_status_code" {
  type        = string
  description = "Status code for target group"
  default     = "200"
}