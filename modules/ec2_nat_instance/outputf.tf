output "id" {
  value       = aws_instance.nat.id
  description = "NAT instance ID"
}

output "interface_id" {
  value       = aws_instance.nat.primary_network_interface_id
  description = "NAT instance network interface ID"
}