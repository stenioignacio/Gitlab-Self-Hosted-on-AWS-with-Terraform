output "id" {
  value       = aws_instance.main.id
  description = "EC2 ID"
}

output "arn" {
  value       = aws_instance.main.arn
  description = "EC2 ARN"
}

output "name" {
  value       = aws_instance.main.tags["Name"]
  description = "EC2 Name tag"
}

output "dns_name" {
  value       = aws_instance.main.private_dns
  description = "EC2 private DNS"
}

output "subnet_id" {
  value       = aws_instance.main.subnet_id
  description = "Subnet ID where the EC2 resides"
}

output "availability_zone" {
  value       = aws_instance.main.availability_zone
  description = "EC2 availability zone"
}
output "private_ip" {
  value       = aws_instance.main.private_ip
  description = "EC2 private IP"
}

output "public_ip" {
  value       = aws_instance.main.public_ip
  description = "EC2 public IP"
}

output "public_dns_name" {
  value       = aws_instance.main.public_dns
  description = "EC2 public DNS"
}

output "private_dns_name" {
  value       = aws_instance.main.private_dns
  description = "EC2 private DNS"
}

output "instance_type" {
  value       = aws_instance.main.instance_type
  description = "EC2 instance type"
}

output "ami_id" {
  value       = aws_instance.main.ami
  description = "EC2 AMI ID"
}