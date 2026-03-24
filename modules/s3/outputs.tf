output "region" {
  value       = aws_s3_bucket.main.region
  description = "S3 bucket region"
}

output "arn" {
  value       = aws_s3_bucket.main.arn
  description = "S3 bucket ARN"
}

output "id" {
  value       = aws_s3_bucket.main.id
  description = "S3 bucket ID"
}

output "name" {
  value       = aws_s3_bucket.main.bucket
  description = "Bucket name"
}

output "regional_domain_name" {
  value       = aws_s3_bucket.main.bucket_regional_domain_name
  description = "S3 regional domain name"
}