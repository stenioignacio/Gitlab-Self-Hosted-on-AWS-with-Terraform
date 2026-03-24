variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "region" {
  type        = string
  description = "Default S3 region"
}

variable "name" {
  type        = string
  description = "Storage bucket name"
}

variable "retention_period_active" {
  type        = bool
  description = "Enable S3 object retention period"
}

variable "retention_days" {
  type        = number
  description = "S3 object retention days"
}