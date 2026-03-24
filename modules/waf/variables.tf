variable "account_project_base_name" {
  type        = string
  description = "Base project name"
  default     = "vpc"
}

variable "resource_association_arn" {
  type        = list(string)
  description = "Resource ARNs to associate with WAF"
}

variable "managed_rule_groups" {
  type = map(object({
    vendor_name          = string
    name                 = string
    priority             = number
    rule_action_override = optional(list(string))
  }))
  description = "List of managed rule groups for the WAF"
}

variable "regional_country_codes_rule" {
  type        = list(string)
  description = "List of geolocation rules for the WAF"
}

variable "logs_retention_period" {
  type        = number
  description = "WAF logs retention period (days)"
}