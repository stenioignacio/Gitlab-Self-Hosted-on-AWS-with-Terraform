resource "aws_subnet" "subnet" {
  count = length(var.subnets)

  vpc_id = var.vpc_id

  cidr_block        = var.subnets[count.index].cidr
  availability_zone = var.subnets[count.index].availability_zone

  tags = {
    Name = var.subnets[count.index].name
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "rt-${var.account_project_base_name}-public-internet-access"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  count = length(var.subnets)

  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

module "parameter_store_public_subnets" {
  source = "../parameter_store"

  count = length(aws_subnet.subnet)

  name  = "/vpc-${var.account_project_base_name}/subnets/public/${var.subnets[count.index].availability_zone}/${var.subnets[count.index].name}/id"
  value = aws_subnet.subnet[count.index].id
}