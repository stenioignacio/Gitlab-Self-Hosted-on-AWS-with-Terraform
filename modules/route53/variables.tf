variable "name" {
  type        = string
  description = "Domain name for Route53 zone"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where private zone will be created"
}

variable "records" {
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))

  default     = []
  description = "A/AAAA/CNAME records with static values"
}