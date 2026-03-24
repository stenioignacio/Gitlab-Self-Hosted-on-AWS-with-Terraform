output "id" {
  value       = aws_route53_zone.main.id
  description = "Route 53 zone ID"
}

output "arn" {
  value       = aws_route53_zone.main.arn
  description = "Route 53 zone ARN"
}

output "records" {
  value       = aws_route53_record.alias[*].fqdn
  description = "FQDNs of records created in the Route 53 zone"
}

output "zone_id" {
  value = aws_route53_zone.main.zone_id
}