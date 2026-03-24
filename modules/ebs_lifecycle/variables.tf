variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "name" {
  type        = string
  description = "Lifecycle policy name"
}

variable "interval" {
  type        = number
  description = "Interval between lifecycle policy runs"
}

variable "interval_unit" {
  type        = string
  description = "Time unit for the interval"
}

variable "times" {
  type        = list(string)
  description = "Execution times for the lifecycle policy"
}

variable "retention_days" {
  type        = number
  description = "Snapshot retention days"
}

variable "tags_to_add" {
  type        = map(string)
  description = "Tags to add to snapshots"
}

variable "target_tags" {
  type        = map(string)
  description = "Target tags for lifecycle policy application"
}