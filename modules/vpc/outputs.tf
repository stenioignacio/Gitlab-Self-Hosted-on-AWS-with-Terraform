output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_name" {
  value       = aws_vpc.main.arn
  description = "VPC ARN"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC IPv4 CIDR range"
}

output "vpc_additional_cidrs" {
  value       = aws_vpc_ipv4_cidr_block_association.main[*].cidr_block
  description = "Additional CIDR ranges in the VPC"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "Internet Gateway ID"
}