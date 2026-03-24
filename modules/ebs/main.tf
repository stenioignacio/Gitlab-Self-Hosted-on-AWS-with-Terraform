resource "aws_ebs_volume" "main" {
  availability_zone = var.availability_zone
  type              = var.type
  size              = var.size
  encrypted         = true
  kms_key_id        = var.kms_key_id

  tags = {
    Name        = format("ebs-%s", var.account_project_base_name)
    Gitlab-Data = "true"
  }
}

resource "aws_volume_attachment" "attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.main.id
  instance_id = var.instance_id
}

module "ebs_lifecycle" {
  source = "../ebs_lifecycle"

  account_project_base_name = var.account_project_base_name

  name = var.account_project_base_name
  target_tags = {
    Gitlab-Data = "true"
  }
  tags_to_add = {
    Backup = "true"
  }
  interval       = 24
  interval_unit  = "HOURS"
  times          = ["03:00"]
  retention_days = 7
}