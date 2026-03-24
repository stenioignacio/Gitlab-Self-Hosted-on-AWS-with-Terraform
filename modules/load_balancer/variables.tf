variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}

variable "internal" {
  type        = bool
  description = "Set whether the Load Balancer is internal"
}

variable "load_balancer_type" {
  type        = string
  description = "Load balancer type"
}

variable "security_group" {
  type        = list(string)
  description = "Security groups for the Load Balancer"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs for the Load Balancer"
}

variable "delete_protection" {
  type        = bool
  description = "Define se a proteção contra destruição está habilitada"
  default     = true
}

variable "logs" {
  type        = bool
  description = "Enable Load Balancer logs to CloudWatch"
}

#Listener HTTP
variable "port_http" {
  type        = string
  description = "HTTP listener port"
}

variable "protocol_http" {
  type        = string
  description = "HTTP listener protocol"
}

variable "default_action_type_http" {
  type        = string
  description = "Default action for HTTP listener"
}

variable "redirect_port" {
  type        = string
  description = "Redirect port"
}

variable "redirect_protocol" {
  type        = string
  description = "Redirect protocol"
}

variable "redirect_status_code" {
  type        = string
  description = "Redirect status code"
}

#Listener HTTPS
variable "port_https" {
  type        = string
  description = "HTTPS listener port"
}

variable "protocol_https" {
  type        = string
  description = "HTTPS listener protocol"
}

variable "ssl_policy_https" {
  type        = string
  description = "SSL policy used for HTTPS rule"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN for HTTPS rule"
  default     = ""
}

variable "default_action_type_https" {
  type        = string
  description = "Default action for HTTPS rule"
}

variable "tg_arn" {
  type        = string
  description = "Target Group ARN for HTTPS rule"
}