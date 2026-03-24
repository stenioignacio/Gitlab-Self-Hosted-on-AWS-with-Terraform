variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the subnet"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block to restrict access to NAT instance in VPC"
}

variable "subnets" {
  description = "List of VPC subnets"
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}

variable "public_subnets" {
  description = "List of public subnet IDs in VPC"
  type        = list(string)
}