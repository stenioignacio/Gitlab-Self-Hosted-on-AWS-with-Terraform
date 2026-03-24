output "arn" {
  value       = aws_ebs_volume.main.arn
  description = "EBS volume ARN"
}
output "id" {
  value       = aws_ebs_volume.main.id
  description = "EBS volume ID"
}
output "type" {
  value       = aws_ebs_volume.main.type
  description = "EBS volume type"
}
output "availability_zone" {
  value       = aws_ebs_volume.main.availability_zone
  description = "EBS volume availability zone"
}
output "size" {
  value       = aws_ebs_volume.main.size
  description = "EBS volume size (GiB)"
}