resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = format("vpc-%s", var.account_project_base_name)
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "main" {
  count = length(var.vpc_additional_cidrs) > 0 ? 1 : 0

  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc_additional_cidrs[count.index]
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("igw-%s", var.account_project_base_name)
  }
}

module "parameter_store_vpc" {
  source = "../parameter_store"

  name  = "/vpc/vpc-${var.account_project_base_name}/id"
  value = aws_vpc.main.id
}

module "parameter_store_igw" {
  source = "../parameter_store"

  name  = "/vpc/vpc-${var.account_project_base_name}/igw/id"
  value = aws_internet_gateway.main.id
}