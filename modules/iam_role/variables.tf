variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "role_name" {
  type        = string
  description = "Role identifier name (pattern 'role-<INPUT>-baseProjectName')"
}

variable "assume_role" {
  type        = string
  description = "Service that will assume the role"
}

variable "permission_effect" {
  type        = string
  description = "Permission effect"
}

variable "permissions" {
  type        = list(string)
  description = "List of permissions for the role"
}

variable "permission_resources_arn" {
  type        = list(string)
  description = "List of service ARNs for permission"
}