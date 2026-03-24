data "aws_ami" "image" {
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

module "key_pair_ec2" {
  source = "../key_pair"

  account_project_base_name = var.account_project_base_name
  name                      = format("%s-%s", var.name, var.account_project_base_name)
  key_algorithm             = var.key_pair_algorithm
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.image.id
  key_name                    = module.key_pair_ec2.name
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  user_data                   = var.user_data_script
  associate_public_ip_address = var.ip_public
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  vpc_security_group_ids      = var.security_group_ids
  monitoring                  = true

  root_block_device {
    volume_size           = var.disk_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  dynamic "instance_market_options" {
    for_each = var.spot_instance ? [1] : []

    content {
      market_type = "spot"
      spot_options {
        max_price = 0.0074
      }
    }
  }

  tags = {
    Name            = format("ec2-%s-%s", var.name, var.account_project_base_name)
    CloudWatchAgent = "true"
    ResourceType    = "ec2"
    InstanceType    = var.instance_type
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami, user_data]
  }

  depends_on = [module.key_pair_ec2]
}

#SSM Agent Permissions
resource "aws_iam_policy" "ssm_agent_policy" {
  name = format("Ec2ProfilePolicy-%s-%s", var.name, var.account_project_base_name)

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = length(var.aditional_role_permissions) > 1 ? concat([
          "ssm:UpdateInstanceInformation",
          "ssm:PutInventory",
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
          "ssm:DescribeSessions",
          "ssm:DescribeInstanceProperties",
          "ssm:DescribeInstanceInformation",
          "ssm:GetDocument",
          "ssm:ListAssociations",
          "ssm:UpdateAssociationStatus",
          "ssm:DescribeAssociation",
          "ssm:GetManifest",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DeleteParameter",
          "ssm:PutParameter",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:SendCommand",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply",
          "s3:GetEncryptionConfiguration",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads",
          "kms:Decrypt",
          "ses:SendRawEmail"
          ], var.aditional_role_permissions
          ) : [
          "ssm:UpdateInstanceInformation",
          "ssm:PutInventory",
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
          "ssm:DescribeSessions",
          "ssm:DescribeInstanceProperties",
          "ssm:DescribeInstanceInformation",
          "ssm:GetDocument",
          "ssm:ListAssociations",
          "ssm:UpdateAssociationStatus",
          "ssm:DescribeAssociation",
          "ssm:GetManifest",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DeleteParameter",
          "ssm:PutParameter",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:SendCommand",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply",
          "s3:GetEncryptionConfiguration",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads",
          "kms:Decrypt",
          "ses:SendRawEmail"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      # Adicione esta declaração para permitir que a instância envie logs para o CloudWatch Logs
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:log-group:/aws/ssm/*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = format("Ec2ssmRole-%s-%s", var.name, var.account_project_base_name)

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

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ssm_agent_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = format("EC2SSMInstanceProfile-%s-%s", var.name, var.account_project_base_name)
  role = aws_iam_role.ec2_ssm_role.name
}

#Install CloudWatch Agent and SSM Association
module "install_cloudwatch_agent" {
  source = "../ec2_cw_agent"

  instance_name = aws_instance.main.tags["Name"]

  target_tag    = "tag:CloudWatchAgent"
  target_values = ["true"]
}

#Secret ID of the EC2 instance
module "secrets" {
  source = "../secret_manager"

  name   = "ec2-instance-id-${aws_instance.main.tags["Name"]}"
  values = aws_instance.main.id
}

#Default Cloudwatch alarms
module "restart_ec2_with_healthcheck_problems" {
  source = "../cloudwatch_check_ec2_fail"

  account_project_base_name = var.account_project_base_name
  region                    = var.account_region

  instance_id   = aws_instance.main.id
  instance_name = aws_instance.main.tags["Name"]
  sns_topic_arn = var.cw_sns_topic_arn
}

module "default_cpu_alarm" {
  source = "../cloudwatch_alarm"

  name                = "CPU-Utilization-ec2-${aws_instance.main.tags["Name"]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 4
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = 80
  datapoints_to_alarm = 3
  period              = 180
  statistic           = "Average"
  alarm_description   = "CPU usage exceeded 80% for EC2 instance ${aws_instance.main.tags["Name"]}"

  dimension = {
    InstanceId   = aws_instance.main.id
    InstanceType = aws_instance.main.instance_type
    ImageId      = aws_instance.main.ami
  }

  sns_topic_arn = var.cw_sns_topic_arn
}

module "default_memory_alarm" {
  source = "../cloudwatch_alarm"

  name                = "MemoryUtilization-ec2-${aws_instance.main.tags["Name"]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 4
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  threshold           = 80
  datapoints_to_alarm = 3
  period              = 180
  statistic           = "Average"
  alarm_description   = "Memory usage exceeded 80% for EC2 instance ${aws_instance.main.tags["Name"]}"

  dimension = {
    InstanceId = aws_instance.main.id
  }

  sns_topic_arn = var.cw_sns_topic_arn
}

module "default_ebs_alarm" {
  source = "../cloudwatch_alarm"

  name                = "VolumeUtilization-ec2-${aws_instance.main.tags["Name"]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  threshold           = 80
  period              = 300
  statistic           = "Average"
  alarm_description   = "Default EBS disk usage exceeded 80% for EC2 instance ${aws_instance.main.tags["Name"]}"

  dimension = {
    InstanceId = aws_instance.main.id
    # InstanceName = aws_instance.main.tags["Name"]
    path   = "/"
    device = "nvme0n1p1"
    fstype = "ext4"
  }

  sns_topic_arn = var.cw_sns_topic_arn
}