resource "aws_kms_key" "main" {
  key_usage           = var.key_usage
  is_enabled          = var.kms_key_enabled
  multi_region        = var.multi_region
  enable_key_rotation = var.key_rotation
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.kms_alias_name}"
  region        = aws_kms_key.main.region
  target_key_id = aws_kms_key.main.id
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id
  policy = jsonencode({
    Id = "Access To Current Account on KMS Key"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "${data.aws_caller_identity.current.account_id}"
        }

        Resource = "*"
        Sid      = "Enable Account permissions"
        # Service = var.services_with_access_to_key
      },
    ]
    Version = "2012-10-17"
  })
}

module "parameter_id" {
  source = "../parameter_store"

  name  = "/kms/${aws_kms_alias.main.name}/id"
  value = aws_kms_alias.main.id
}

module "parameter_arn" {
  source = "../parameter_store"

  name  = "/kms/${aws_kms_alias.main.name}/arn"
  value = aws_kms_alias.main.arn
}