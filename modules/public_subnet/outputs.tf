output "subnet_id" {
  value       = aws_subnet.subnet[*].id
  description = "Subnet ID"
}

output "subnet_arn" {
  value       = aws_subnet.subnet[*].arn
  description = "Subnet ARN"
}

output "internet_gateway_id" {
  value       = aws_route.public.gateway_id
  description = "Internet Gateway ID associated with the public route table"
}

output "route_table_id" {
  value       = aws_route_table.public[*].id
  description = "Route Table ID"
}

output "route_table_arn" {
  value       = aws_route_table.public[*].arn
  description = "Route Table ARN"
}