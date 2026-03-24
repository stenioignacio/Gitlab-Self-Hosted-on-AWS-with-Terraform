resource "aws_lb" "main" {
  name                       = format("lb-%s", var.account_project_base_name)
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_group
  subnets                    = var.subnets
  enable_deletion_protection = var.delete_protection
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.port_http
  protocol          = var.protocol_http

  default_action {
    type = var.default_action_type_http

    redirect {
      port        = var.redirect_port
      protocol    = var.redirect_protocol
      status_code = var.redirect_status_code
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.port_https
  protocol          = var.protocol_https
  ssl_policy        = var.ssl_policy_https
  certificate_arn   = var.certificate_arn

  default_action {
    type             = var.default_action_type_https
    target_group_arn = var.tg_arn
  }
}

module "parameter_store_lb_id" {
  source = "../parameter_store"

  name  = "/lb-${var.account_project_base_name}/application/${aws_lb.main.internal == true ? "internal" : "public"}/id"
  value = aws_lb.main.id
}

module "parameter_store_lb_arn" {
  source = "../parameter_store"

  name  = "/lb-${var.account_project_base_name}/application/${aws_lb.main.internal == true ? "internal" : "public"}/arn"
  value = aws_lb.main.arn
}

module "parameter_store_listener_http" {
  source = "../parameter_store"

  name  = "/lb-${var.account_project_base_name}/application/${aws_lb.main.internal == true ? "internal" : "public"}/listener/http/id"
  value = aws_lb_listener.http.id
}

module "parameter_store_listener_https" {
  source = "../parameter_store"

  name  = "/lb-${var.account_project_base_name}/application/${aws_lb.main.internal == true ? "internal" : "public"}/listener/https/id"
  value = aws_lb_listener.https.id
}