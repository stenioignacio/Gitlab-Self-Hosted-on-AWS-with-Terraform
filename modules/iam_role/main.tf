data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = format("role-${var.role_name}-%s", var.account_project_base_name)
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "permission" {
  statement {
    effect    = var.permission_effect
    actions   = var.permissions
    resources = var.permission_resources_arn
  }
}

resource "aws_iam_policy" "policy" {
  name   = format("policy-for-%s-%s", aws_iam_role.role.id, var.account_project_base_name)
  policy = data.aws_iam_policy_document.permission.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}