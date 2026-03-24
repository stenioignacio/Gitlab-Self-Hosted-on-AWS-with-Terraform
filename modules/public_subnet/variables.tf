variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the subnet"
}

variable "internet_gateway_id" {
  type        = string
  description = "Internet Gateway ID"
}

variable "subnets" {
  description = "List of VPC subnets"
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}