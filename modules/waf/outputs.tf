output "arn" {
  value       = aws_wafv2_web_acl.main.arn
  description = "Waf ARN"
}

output "id" {
  value       = aws_wafv2_web_acl.main.id
  description = "Waf ID"
}

output "name" {
  value       = aws_wafv2_web_acl.main.name
  description = "Waf name"
}