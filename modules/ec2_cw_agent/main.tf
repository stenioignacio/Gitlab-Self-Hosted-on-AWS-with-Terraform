#Configure SSM Parameter for CloudWatch Agent configuration
resource "aws_ssm_parameter" "cw_agent_config" {
  name = "CloudwatchAgent-config-linux-${var.instance_name}"
  type = "String"
  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user                 = "cwagent"
    }
    metrics = {
      namespace = "CWAgent"
      metrics_collected = {
        cpu = {
          measurement = [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ]
          metrics_collection_interval = 60
          resources                   = ["*"]
          totalcpu                    = false
        }
        disk = {
          measurement                 = ["used_percent"]
          metrics_collection_interval = 60
          resources                   = ["*"]
        }
        diskio = {
          measurement = [
            "io_time",
            "read_bytes",
            "write_bytes",
            "reads",
            "writes"
          ]
          metrics_collection_interval = 60
          resources                   = ["*"]
        }
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 60
        }
        netstat = {
          measurement                 = ["tcp_established", "tcp_time_wait"]
          metrics_collection_interval = 60
        }
        swap = {
          measurement                 = ["swap_used_percent"]
          metrics_collection_interval = 60
        }
      }
    }
  })

  lifecycle {
    create_before_destroy = true
  }
}

#Install cloudwatch agent
resource "aws_ssm_association" "install_cw_agent" {
  name             = "AWS-ConfigureAWSPackage"
  association_name = "Install-CloudWatch-Agent"

  parameters = {
    action = var.action
    name   = var.package_name
  }

  targets {
    key    = var.target_tag
    values = var.target_values
  }

  schedule_expression = "rate(30 minutes)"
  max_concurrency     = "50%"
  max_errors          = "5%"
}

#Configure cloudwatch agent
resource "aws_ssm_association" "configure_cw_agent" {
  name             = "AmazonCloudWatch-ManageAgent"
  association_name = "Configure-CloudWatch-Agent-Linux"

  targets {
    key    = var.target_tag
    values = var.target_values
  }

  targets {
    key    = "tag:os"
    values = ["Linux"]
  }

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalRestart               = "yes"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = aws_ssm_parameter.cw_agent_config.name
  }

  schedule_expression = "rate(40 minutes)"

  depends_on = [aws_ssm_association.install_cw_agent, aws_ssm_parameter.cw_agent_config]
}

