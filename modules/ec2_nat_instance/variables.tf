variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "name" {
  type        = string
  description = "NAT instance name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for NAT instance"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block to restrict access to NAT instance in VPC"
}