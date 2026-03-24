output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "Primary VPC CIDR"
}

output "vpc_additional_cidrs" {
  value       = module.vpc.vpc_additional_cidrs
  description = "Additional VPC CIDRs"
}

output "private_subnets_id" {
  value       = module.private_subnets[*].subnet_id
  description = "Private subnet IDs in VPC"
}

output "public_subnets_id" {
  value       = module.public_subnets[*].subnet_id
  description = "Public subnet IDs in VPC"
}

output "gitlab_dns" {
  value       = var.route53.name
  description = "GitLab DNS"
}

output "ec2_host" {
  value       = module.ec2.dns_name
  description = "EC2 public IP"
  sensitive   = true
}

output "rds_host" {
  value       = data.aws_ssm_parameter.rds_host
  description = "RDS endpoint used by GitLab"
  sensitive   = true
}

output "lb_internal_ips" {
  value       = module.lb.alb_private_ips
  sensitive   = true
  description = "List of private IPs for the Load Balancer"
}