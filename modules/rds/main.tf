resource "aws_db_subnet_group" "main" {
  name       = substr(format("subnet-group-%s", var.account_project_base_name), 0, 32)
  subnet_ids = var.private_subnets
}

resource "random_password" "main" {
  length           = var.password_lentgh
  special          = true
  override_special = "!#%$"
}

resource "aws_db_instance" "main" {
  identifier              = format("rds-%s", var.account_project_base_name)
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.account_project_base_name
  password                = random_password.main.result
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws_db_subnet_group.main.name
  backup_retention_period = var.backup_retention_period
  vpc_security_group_ids  = var.security_group
  storage_type            = var.storage_type

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [db_name, username, password]
  }

  depends_on = [random_password.main, aws_db_subnet_group.main]
}

resource "aws_db_instance_automated_backups_replication" "main" {
  source_db_instance_arn = aws_db_instance.main.arn
}

module "secret" {
  source = "../secret_manager"

  name = "${var.account_project_base_name}_rds_credentials"
  values = {
    "host"     = aws_db_instance.main.address
    "port"     = aws_db_instance.main.port
    "username" = aws_db_instance.main.username
    "password" = aws_db_instance.main.password
  }
}

module "host_parameter" {
  source = "../parameter_store"

  name  = "/rds/${var.account_project_base_name}/host"
  value = aws_db_instance.main.address
}

module "port_parameter" {
  source = "../parameter_store"

  name  = "/rds/${var.account_project_base_name}/port"
  value = aws_db_instance.main.port
}