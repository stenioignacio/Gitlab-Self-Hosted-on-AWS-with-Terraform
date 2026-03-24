resource "tls_private_key" "main" {
  algorithm = var.key_algorithm
}

resource "aws_key_pair" "main" {
  key_name   = format("key-pair-%s-%s", var.name, var.account_project_base_name)
  public_key = tls_private_key.main.public_key_openssh

  lifecycle {
    ignore_changes = [public_key]
  }
}

module "secrets" {
  source = "../secret_manager"

  name = aws_key_pair.main.key_name
  values = {
    private_key    = tls_private_key.main.private_key_pem
    public_key     = tls_private_key.main.public_key_openssh
    public_key_pem = tls_private_key.main.public_key_pem
  }
}