output "subnet_id" {
  value       = aws_subnet.subnet[*].id
  description = "Subnet ID"
}

output "subnet_arn" {
  value       = aws_subnet.subnet[*].arn
  description = "Subnet ARN"
}

# output "nat_id" {
#   value = aws_nat_gateway.main[*].id
#   description = "NAT Gateway ID associated with the private subnet"
# }

output "route_table_id" {
  value       = aws_route_table.private[*].id
  description = "Route Table ID"
}

output "route_table_arn" {
  value       = aws_route_table.private[*].arn
  description = "Route Table ARN"
}

output "ec2_nat_interface_id" {
  value = module.ec2_nat.interface_id
}