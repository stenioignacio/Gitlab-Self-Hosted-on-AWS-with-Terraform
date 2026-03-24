resource "aws_wafv2_web_acl" "main" {
  name  = format("waf-%s", var.account_project_base_name)
  scope = "REGIONAL"
  default_action {
    block {}
  }

  rule {
    name     = "RegionalRule"
    priority = 9999
    action {
      allow {}
    }

    statement {
      geo_match_statement {
        country_codes = var.regional_country_codes_rule
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RegionalRule"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.managed_rule_groups

    content {
      name     = rule.key # Use the map key as the rule name
      priority = rule.value.priority
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          vendor_name = rule.value.vendor_name
          name        = rule.value.name

          dynamic "rule_action_override" {
            for_each = coalesce(rule.value.rule_action_override, [])
            content {
              name = rule_action_override.value
              action_to_use {
                allow {}
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${rule.key}-Metrics" # Metric name based on the key
        sampled_requests_enabled   = true
      }
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = format("waf-metric-%s", var.account_project_base_name)
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "waf_assoc" {
  count = length(var.resource_association_arn)

  resource_arn = var.resource_association_arn[count.index]
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

#Logs
resource "aws_cloudwatch_log_group" "main" {
  name              = format("aws-waf-logs-%s-%s", aws_wafv2_web_acl.main.name, var.account_project_base_name)
  retention_in_days = var.logs_retention_period
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = ["${aws_cloudwatch_log_group.main.arn}:*"]
  resource_arn            = aws_wafv2_web_acl.main.arn

  depends_on = [
    aws_cloudwatch_log_group.main,
    aws_wafv2_web_acl.main
  ]
}

resource "aws_cloudwatch_log_resource_policy" "main" {
  policy_document = data.aws_iam_policy_document.main.json
  policy_name     = format("policy-waf-%s", aws_wafv2_web_acl.main.name)
}

data "aws_iam_policy_document" "main" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.main.arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}