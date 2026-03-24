output "domain_name" {
  value       = aws_cloudfront_distribution.main.domain_name
  description = "CloudFront domain name"
}

output "arn" {
  value       = aws_cloudfront_distribution.main.arn
  description = "CloudFront ARN"
}

output "origin" {
  value       = aws_cloudfront_distribution.main.origin
  description = "CloudFront origin"
}

output "id" {
  value       = aws_cloudfront_distribution.main.id
  description = "CloudFront ID"
}