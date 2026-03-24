variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "vpc_cidr" {
  type        = string
  description = "Primary VPC CIDR"
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable resolution of 'dns_names' within the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS support"
}

variable "vpc_additional_cidrs" {
  type        = list(string)
  default     = []
  description = "List of additional CIDRs for the VPC"
}