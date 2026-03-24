resource "aws_sns_topic" "main" {
  name = format("sns-topic-%s-%s", var.name, var.account_project_base_name)
}

resource "aws_sns_topic_subscription" "main" {
  count = length(var.endpoint)

  topic_arn = aws_sns_topic.main.arn
  protocol  = var.protocol
  endpoint  = var.endpoint[count.index]
}