variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "domain_name" {
  type        = string
  description = "Route53 domain name to create the certificate"
}

variable "domain_alternative_names" {
  type        = list(string)
  description = "Other domain names for the certificate"
}

variable "validation_method" {
  type        = string
  description = "Validation type for the certificate"
}

variable "record_overwrite" {
  type        = bool
  description = "Allows overwriting the DNS record"
}

variable "record_ttl" {
  type        = number
  description = "TTL for the DNS record"
}
