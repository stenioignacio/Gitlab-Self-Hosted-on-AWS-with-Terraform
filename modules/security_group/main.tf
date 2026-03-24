resource "aws_security_group" "main" {
  name_prefix = format("%s-%s", var.name, var.account_project_base_name)
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type                     = "ingress"
  cidr_blocks              = var.ingress_rules[count.index].cidr_blocks
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id
  from_port                = var.ingress_rules[count.index].from_port
  to_port                  = var.ingress_rules[count.index].to_port
  protocol                 = var.ingress_rules[count.index].protocol
  security_group_id        = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type                     = "egress"
  cidr_blocks              = var.egress_rules[count.index].cidr_blocks
  source_security_group_id = var.egress_rules[count.index].source_security_group_id
  from_port                = var.egress_rules[count.index].from_port
  to_port                  = var.egress_rules[count.index].to_port
  protocol                 = var.egress_rules[count.index].protocol
  security_group_id        = aws_security_group.main.id
}

module "sg_parameter" {
  source = "../parameter_store"

  name  = "/sg/${var.name}/id"
  value = aws_security_group.main.id
}