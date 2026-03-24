variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "name" {
  type        = string
  description = "Security group name"
}

variable "ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of ingress rules"
}

variable "egress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of egress rules"
}