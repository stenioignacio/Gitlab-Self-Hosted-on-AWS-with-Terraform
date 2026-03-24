resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.domain_alternative_names
  validation_method         = var.validation_method
}
