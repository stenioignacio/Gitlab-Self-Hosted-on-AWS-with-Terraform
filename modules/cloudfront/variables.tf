variable "s3_bucket_regional_domain_name" {
  type        = string
  description = "S3 bucket regional domain name"
}

variable "s3_origin_id" {
  type        = string
  description = "S3 origin ID"
}

variable "aliases" {
  type        = list(string)
  description = "List of aliases for CloudFront DNS"
}

variable "default_object" {
  type        = string
  description = "Default object to serve from CloudFront"
}

variable "allowed_methods" {
  type        = list(string)
  description = "Allowed HTTP methods"
}

variable "cached_methods" {
  type        = list(string)
  description = "Cached HTTP methods"
}

variable "geo_restriction_type" {
  type        = string
  description = "Geo restriction type"
  default     = "whitelist"
}

variable "geo_restriction_contry" {
  type        = list(string)
  description = "Country codes for geo restriction"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN for CloudFront"
}

variable "connection_attempts" {
  type        = number
  description = "Number of allowed connections"
  default     = 3
}

variable "connection_timeout" {
  type        = number
  description = "Connection timeout (seconds)"
  default     = 10
}

variable "lb_dns" {
  type        = string
  description = "Load Balancer DNS"
}

variable "origin_group_id" {
  type        = string
  description = "Origin group ID"
}

variable "failover_status_codes" {
  type        = list(string)
  description = "Status codes for failover"
  default     = ["502", "503", "504"]
}

variable "s3_associated" {
  type        = bool
  description = "Enable CloudFront private access policy"
  default     = false
}

variable "s3_id" {
  type        = string
  description = "S3 ID"
  default     = ""
}

variable "s3_arn" {
  type        = string
  description = "S3 ARN"
}