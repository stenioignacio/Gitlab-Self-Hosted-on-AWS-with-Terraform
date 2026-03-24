data "aws_ami" "main" {
  most_recent = true
  owners      = var.img_owner

  filter {
    name   = "name"
    values = var.image
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_policy" "main" {
  name = format("Instance-Profile-%s-%s", var.name, var.account_project_base_name)

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = var.instance_profile_permissions,
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "main" {
  name = format("Instance-Profile-%s-%s", var.name, var.account_project_base_name)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attach" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "main" {
  name = format("asg-Instance-Profile-%s-%s", var.name, var.account_project_base_name)
  role = aws_iam_role.main.name
}

resource "aws_launch_template" "main" {
  name_prefix            = format("launch-template-gitlab-runner-${replace(var.instance_type, ".", "-")}-%s", var.spot_instance == true ? "spot" : "dedicated")
  image_id               = data.aws_ami.main.image_id
  instance_type          = var.instance_type
  user_data              = var.user_data_script
  vpc_security_group_ids = var.security_group_ids
  update_default_version = true
  ebs_optimized          = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = "50"
      volume_type = "gp3"
    }
  }

  dynamic "tag_specifications" {
    for_each = toset(var.tag_specifications_resource)

    content {
      resource_type = tag_specifications.value
      tags = {
        Name          = "Runners ${startswith(var.instance_type, "t4g") ? "ARM64" : "AMD64"} [${var.instance_type}.${var.spot_instance == true ? "spot" : "dedicated"}]"
        gitlab-runner = "${var.instance_type}.${var.spot_instance == true ? "spot" : "dedicated"}"
        ResourceType  = tag_specifications.value
        InstanceType  = var.instance_type
      }
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name                  = format("gitlab-runner-%s-%s", replace(var.instance_type, ".", "-"), var.spot_instance == true ? "spot" : "dedicated")
  vpc_zone_identifier   = var.subnets
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  protect_from_scale_in = true
  enabled_metrics       = ["GroupInServiceInstances", "GroupStandbyInstances", "GroupTotalInstances"]

  tag {
    key                 = "Name"
    value               = "Runners ${startswith(var.instance_type, "t4g") ? "ARM64" : "AMD64"} [${var.instance_type}.${var.spot_instance == true ? "spot" : "dedicated"}]"
    propagate_at_launch = true
  }

  tag {
    key                 = "gitlab-runner"
    value               = "${var.instance_type}.${var.spot_instance == true ? "spot" : "dedicated"}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ResourceType"
    value               = "ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "InstanceType"
    value               = var.instance_type
    propagate_at_launch = true
  }

  mixed_instances_policy {

    dynamic "instances_distribution" {
      for_each = var.spot_instance ? [1] : []

      content {
        spot_allocation_strategy = "lowest-price"
      }
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version            = "$Latest"
      }
    }
  }

  dynamic "warm_pool" {
    for_each = var.warm_pool_activated != false ? [1] : []

    content {
      pool_state                  = var.warm_pool_pool_state
      min_size                    = var.warm_pool_min_size
      max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity

      instance_reuse_policy {
        reuse_on_scale_in = true
      }
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  count = length(var.threshold) > 0 ? length(var.threshold) : 0

  alarm_name          = "asg-limit-alarm-${var.threshold[count.index]}-${startswith(var.instance_type, "t4g") ? "ARM64" : "AMD64"} [${var.instance_type}.${var.spot_instance == true ? "spot" : "dedicated"}]"
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold[count.index]
  alarm_description   = var.alarm_description

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  datapoints_to_alarm = var.datapoints_to_alarm

  alarm_actions = [var.sns_topic_arn]
}
