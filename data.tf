data "aws_ssm_parameter" "vpc" {
  name = var.ssm_vpc
}

data "aws_ssm_parameter" "public_subnets" {
  count = length(var.ssm_public_subnets)
  name  = var.ssm_public_subnets[count.index]
}

data "aws_ssm_parameter" "private_subnets" {
  count = length(var.ssm_private_subnets)
  name  = var.ssm_private_subnets[count.index]
}

data "aws_ssm_parameter" "gitlab_sg" {
  name = var.ec2_sg_gitlab
}

#RDS
data "aws_ssm_parameter" "rds_host" {
  name = var.ssm_rds_host
}
data "aws_ssm_parameter" "rds_port" {
  name = var.ssm_rds_port
}
data "aws_secretsmanager_secret" "secret" {
  name = var.secret_rds_name
}
data "aws_secretsmanager_secret_version" "user_and_password" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}