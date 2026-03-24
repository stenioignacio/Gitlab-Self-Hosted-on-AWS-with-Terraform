variable "account_project_base_name" {
  type        = string
  description = "Base project name"
  default     = "vpc"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone in which the EBS volume will be created."
}

variable "type" {
  type        = string
  description = "The type of the EBS volume (e.g., gp2, io1, st1)."
  default     = "gp3"
}

variable "size" {
  type        = number
  description = "The size of the EBS volume in GiB."
}

variable "instance_id" {
  type        = string
  description = "The ID of the instance to which the volume will be attached."
}

variable "kms_key_id" {
  type        = string
  description = "The KMS key ID to use for encryption."
  default     = null
}