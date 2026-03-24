resource "aws_subnet" "subnet" {
  count = length(var.subnets)

  vpc_id = var.vpc_id

  cidr_block        = var.subnets[count.index].cidr
  availability_zone = var.subnets[count.index].availability_zone

  tags = {
    Name = var.subnets[count.index].name
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = {
    Name = format("rt-%s-private", var.account_project_base_name)
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.subnets)

  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

module "parameter_store_private_subnets" {
  source = "../parameter_store"

  count = length(aws_subnet.subnet)

  name  = "/vpc-${var.account_project_base_name}/subnets/private/${var.subnets[count.index].availability_zone}/${var.subnets[count.index].name}/id"
  value = aws_subnet.subnet[count.index].id
}

module "ec2_nat" {
  source = "../ec2_nat_instance"

  account_project_base_name = var.account_project_base_name

  vpc_id    = var.vpc_id
  vpc_cidr  = var.vpc_cidr
  subnet_id = var.public_subnets[1]
  name      = "nat"
}

resource "aws_route" "ec2_nat" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private.id
  network_interface_id   = module.ec2_nat.interface_id
}

# If you want to use a NAT Gateway instead of an EC2 NAT Instance, you can uncomment the code below and comment the code above.
# resource "aws_eip" "eip" {
#   domain = "vpc"

#   tags = {
#     Name = format("eip-nat-%s", var.account_project_base_name)
#   }
# }

# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.eip.id

#   subnet_id = var.public_subnets[0]

#   tags = {
#     Name = format("nat-%s", var.account_project_base_name)
#   }
# }

# resource "aws_route" "private" {
#   destination_cidr_block = "0.0.0.0/0"

#   route_table_id = aws_route_table.private.id

#   gateway_id = aws_nat_gateway.main.id

# }