variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "key_usage" {
  type        = string
  description = "KMS key usage type"
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_key_enabled" {
  type        = string
  description = "Enable KMS key"
  default     = "true"
}

variable "multi_region" {
  type        = string
  description = "Set KMS key multi-region"
  default     = "false"
}

variable "key_rotation" {
  type        = string
  description = "Enable automatic KMS key rotation"
  default     = "false"
}

variable "kms_alias_name" {
  type        = string
  description = "KMS alias name"
}

variable "services_with_access_to_key" {
  type        = list(string)
  description = "List of services allowed to use the KMS key"
}