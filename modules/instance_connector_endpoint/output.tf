output "id" {
  value       = aws_ec2_instance_connect_endpoint.main.id
  description = "Endpoint ID"
}

output "arn" {
  value       = aws_ec2_instance_connect_endpoint.main.arn
  description = "Endpoint ARN"
}

output "subnet_endpoint_id" {
  value       = aws_ec2_instance_connect_endpoint.main.subnet_id
  description = "Endpoint subnet ID"
}