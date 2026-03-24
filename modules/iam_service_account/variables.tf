variable "name" {
  type        = string
  description = "IAM user name"
}

variable "permission_effect" {
  type        = string
  description = "Permission effect"
}

variable "permissions" {
  type        = list(string)
  description = "List of permissions for the service account"
}

variable "permission_resources_arn" {
  type        = list(string)
  description = "List of service ARNs for permission"
}