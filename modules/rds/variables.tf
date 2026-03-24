variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of IDs for the private subnets"
}

variable "password_lentgh" {
  type        = number
  description = "Password length for the postgres user"
  default     = 20
}

variable "allocated_storage" {
  type        = number
  description = "RDS allocated storage size (GB)"
}

variable "engine" {
  type        = string
  description = "RDS engine type"
}

variable "engine_version" {
  type        = string
  description = "RDS engine version"
}

variable "storage_type" {
  type        = string
  description = "RDS storage type"
  default     = "gp3"
}
variable "db_name" {
  type        = string
  description = "Database name created on the RDS"
}

# variable "engine_version" {
#   type = string
#   description = "Versao da engine para o RDS"
# }

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot when the database is destroyed"
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days for daily backup retention"
}

variable "security_group" {
  type        = list(string)
  description = "Security group IDs"
}