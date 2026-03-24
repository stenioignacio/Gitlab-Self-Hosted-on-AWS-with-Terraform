resource "aws_ssm_parameter" "main" {
  name  = var.name
  type  = var.type
  value = var.value
}