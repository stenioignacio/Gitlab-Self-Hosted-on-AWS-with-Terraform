resource "aws_lb_target_group" "main" {
  name_prefix = format("%s", var.account_project_base_name)
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id


  health_check {
    protocol            = var.protocol
    port                = var.port
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = var.matcher_status_code
  }

}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.target_id
  port             = var.port
}