variable "name" {
  type        = string
  description = "Parameter Store name"
}

variable "type" {
  type        = string
  default     = "String"
  description = "Type of the stored parameter value"
}

variable "value" {
  type        = string
  description = "Value to be stored in the parameter"
}