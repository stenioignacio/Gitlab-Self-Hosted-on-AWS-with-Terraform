output "id" {
  value       = aws_acm_certificate.main.id
  description = "Certificate ID"
}

output "arn" {
  value       = aws_acm_certificate.main.arn
  description = "Certificate ARN"
}

output "domain_validation_options" {
  value       = aws_acm_certificate.main.domain_validation_options
  description = "Domain validation options for the certificate"
}
