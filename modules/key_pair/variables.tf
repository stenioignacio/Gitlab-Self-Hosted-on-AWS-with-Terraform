variable "account_project_base_name" {
  type        = string
  description = "Base project name"
  default     = "vpc"
}
variable "account_region" {
  type        = string
  description = "AWS account region"
  default     = "us-east-1"
}
variable "key_algorithm" {
  type        = string
  description = "Key algorithm"
}
variable "name" {
  type        = string
  description = "Key pair name"
}