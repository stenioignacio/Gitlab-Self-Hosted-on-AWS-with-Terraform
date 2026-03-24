output "id" {
  value       = aws_lb.main.id
  description = "Load Balancer ID"
}

output "arn" {
  value       = aws_lb.main.arn
  description = "Load Balancer ARN"
}

output "dns_name" {
  value       = aws_lb.main.dns_name
  description = "Load Balancer DNS name"
}

output "type" {
  value       = aws_lb.main.load_balancer_type
  description = "Load Balancer type"
}

output "internal" {
  value       = aws_lb.main.internal
  description = "Indicates whether the Load Balancer is internal or external"
}

data "aws_network_interfaces" "alb_enis" {
  for_each = nonsensitive(aws_lb.main.subnets)

  filter {
    name   = "description"
    values = ["ELB ${aws_lb.main.arn_suffix}"]
  }

  filter {
    name   = "subnet-id"
    values = [each.value]
  }

  filter {
    name   = "status"
    values = ["in-use"]
  }
}

data "aws_network_interface" "alb_eni" {
  for_each = nonsensitive(aws_lb.main.subnets)
  id       = data.aws_network_interfaces.alb_enis[each.key].ids[0]
}

output "alb_private_ips" {
  value       = [for eni in data.aws_network_interface.alb_eni : eni.private_ip]
  description = "Private Load Balancer ENI Network Interface"
}