resource "aws_secretsmanager_secret" "secret" {
  name = var.name
}

resource "aws_secretsmanager_secret_version" "values" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = can(keys(var.values)) ? jsonencode(var.values) : tostring(var.values)
}