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

variable "name" {
  type        = string
  description = "EC2 instance name"
}
variable "img_owner" {
  type        = list(string)
  description = "Image owner"
}
variable "image" {
  type        = list(string)
  description = "EC2 image name"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "subnet_id" {
  type        = string
  description = "Subnet ID for EC2"
}
variable "user_data_script" {
  type        = string
  description = "Path to EC2 user data script"
}
variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for EC2"
}
variable "ip_public" {
  type        = bool
  description = "Enable public IP on EC2"
  default     = false
}
variable "disk_size" {
  type        = number
  description = "EC2 disk size (GB)"
}
variable "disk_type" {
  type        = string
  description = "EC2 disk type"
  default     = "gp3"
}
variable "disk_encription" {
  type        = bool
  description = "Enable disk encryption"
  default     = true
}
variable "spot_instance" {
  type        = bool
  description = "Enable spot instance"
  default     = false
}
variable "aditional_role_permissions" {
  type        = list(string)
  description = "Additional permissions for the instance"
  default     = []
}
variable "cw_sns_topic_arn" {
  type        = string
  description = "CloudWatch SNS topic ARN"
}
variable "key_pair_algorithm" {
  type        = string
  description = "Key pair algorithm"
  default     = "RSA"
}