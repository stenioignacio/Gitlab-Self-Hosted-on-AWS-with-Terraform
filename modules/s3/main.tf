resource "aws_s3_bucket" "main" {
  bucket = format("gj-s3-%s-%s", var.account_project_base_name, var.name)

  region = var.region
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_ownership_controls.main]

  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = var.retention_period_active == true ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    id = "retention-rule"
    expiration {
      days = var.retention_days
    }
    status = "Enabled"
  }
}