resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id = var.subnet_id

  tags = {
    Name = "Private Connect Endpoint Ec2 - ${var.account_project_base_name}"
  }
}