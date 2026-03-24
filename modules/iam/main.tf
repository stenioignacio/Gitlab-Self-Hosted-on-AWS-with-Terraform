resource "aws_iam_user" "service_user" {
  name = var.name
}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.service_user.name
}

data "aws_iam_policy_document" "permission" {
  statement {
    effect    = var.permission_effect
    actions   = var.permissions
    resources = var.permission_resources_arn
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = format("policy-%s", var.name)
  user   = aws_iam_user.service_user.name
  policy = data.aws_iam_policy_document.permission.json
}

module "secret" {
  source = "../secret_manager"

  name = "${aws_iam_user.service_user.name}-access-and-secret-key"
  values = {
    "Access-Key" = aws_iam_access_key.key.id
    "Secret-Key" = aws_iam_access_key.key.secret
  }
}