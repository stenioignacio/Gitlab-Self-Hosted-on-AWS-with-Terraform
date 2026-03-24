account_id                = "your-account-id" #replace later with the final value
account_name              = "DevOps"
account_region            = "us-east-1"
account_project_base_name = "gitlab"
default_tags = {
  "Project" = "Gitlab-Self-Hosted"
  "Owner"   = "stenio ignacio"
  "Team"    = "DevOps"
}

# Network definitions
vpc_cidr = "10.114.12.0/22"

public_subnets = [
  {
    name              = "gitlab-public-a"
    cidr              = "10.114.12.0/27"
    availability_zone = "us-east-1a"
  },
  {
    name              = "gitlab-public-b"
    cidr              = "10.114.12.32/27"
    availability_zone = "us-east-1b"
  },
  {
    name              = "gitlab-public-c"
    cidr              = "10.114.12.64/27"
    availability_zone = "us-east-1c"
  }
]

private_subnets = [
  {
    name              = "gitlab-private-a"
    cidr              = "10.114.12.96/27"
    availability_zone = "us-east-1a"
  },
  {
    name              = "gitlab-private-b"
    cidr              = "10.114.12.128/27"
    availability_zone = "us-east-1b"
  },
  {
    name              = "gitlab-private-c"
    cidr              = "10.114.12.160/27"
    availability_zone = "us-east-1c"
  }
]

#RDS
sql_engine                  = "postgres"
sql_engine_version          = "16.8"
sql_instance_class          = "db.t4g.small"
sql_allocated_storage       = 20
sql_backup_retention_period = 7
sql_database_name           = "gitlabhq_production"
rds_ingress_rules           = []
rds_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
ec2_sg_gitlab = "/sg/gitlab-host/id"

#Network imports from SSM Parameter Store(you can modify it)
ssm_vpc = "/vpc/vpc-devops/id"
ssm_public_subnets = [
  "/vpc-devops/subnets/public/us-east-1a/gitlab-public-a/id",
  "/vpc-devops/subnets/public/us-east-1b/gitlab-public-b/id",
  "/vpc-devops/subnets/public/us-east-1c/gitlab-public-c/id"
]
ssm_private_subnets = [
  "/vpc-devops/subnets/private/us-east-1a/gitlab-private-a/id",
  "/vpc-devops/subnets/private/us-east-1b/gitlab-private-b/id",
  "/vpc-devops/subnets/private/us-east-1c/gitlab-private-c/id"
]

#DNS Imports
domain_name      = "your-domain.com.br"
private_zone     = false
record_overwrite = true
record_ttl       = 60

#EBS
ebs_availability_zone = "us-east-1b"
ebs_size              = 150

#Ec2
ec2_name          = "host"
ec2_img_owner     = ["099720109477"]
ec2_image         = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
ec2_ip_public     = false
ec2_instance_type = "r8g.medium"
ec2_disk_size     = 30
ec2_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
ec2_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
object_storage_service_account = {
  name              = "gitlab-object-storage"
  permission_effect = "Allow"
  permissions = [
    "s3:ListBucket",
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject"
  ]
  permission_resources_arn = [
    "arn:aws:s3:::s3-gitlab-*",
    "arn:aws:s3:::s3-gitlab-*/*"
  ]
}

#Ec2 Runner Manager
ec2_runner_manager = {
  name          = "runner-manager"
  img_owner     = ["099720109477"]
  image         = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type = "t4g.medium"
  disk_size     = 10
  ip_public     = false
}
ec2_runner_manager_ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
ec2_runner_manager_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
ec2_runner_service_account = {
  name              = "gitlab-runner-manager-autoscaler"
  permission_effect = "Allow"
  permissions = [
    "ec2:*"
  ]
  permission_resources_arn = [
    "*"
  ]
}
runner_manager_configs = {
  idleCount_arm64 = 0
  idleCount_amd64 = 0
  idleTime        = "8m0s"
  maxBuilds       = 100
}
ec2_runner_s3_cache_service_account = {
  name                     = "gitlab-runner-s3-cache"
  permission_effect        = "Allow"
  permissions              = ["s3:*"]
  permission_resources_arn = ["*"]
}
autoscaling_configs_for_runners_amd64 = {
  name               = "runner-amd64"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  instance_type      = "t3a.small"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_amd64_medium = {
  name               = "runner-amd64-medium"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  instance_type      = "t3a.medium"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_amd64_large = {
  name               = "runner-amd64-large"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  instance_type      = "t3a.large"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_amd64_dedicated = {
  name               = "runner-amd64-dedicated"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  instance_type      = "t3a.small"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
  warm_pool_activated                   = true
  warm_pool_pool_state                  = "Stopped"
  warm_pool_min_size                    = 1
  warm_pool_max_group_prepared_capacity = 1
}
autoscaling_configs_for_runners_amd64_medium_dedicated = {
  name               = "runner-amd64-medium-dedicated"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  instance_type      = "t3a.medium"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
  warm_pool_activated                   = true
  warm_pool_pool_state                  = "Stopped"
  warm_pool_min_size                    = 1
  warm_pool_max_group_prepared_capacity = 1
}
autoscaling_configs_for_runners_amd64_large_dedicated = {
  name               = "runner-amd64-large-dedicated"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  instance_type      = "t3a.large"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_arm64 = {
  name               = "runner-arm64"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type      = "t4g.small"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_arm64_medium = {
  name               = "runner-arm64-medium"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type      = "t4g.medium"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_arm64_large = {
  name               = "runner-arm64-large"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type      = "t4g.large"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_arm64_dedicated = {
  name               = "runner-arm64-dedicated"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type      = "t4g.small"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
  warm_pool_activated                   = true
  warm_pool_pool_state                  = "Stopped"
  warm_pool_min_size                    = 1
  warm_pool_max_group_prepared_capacity = 1
}
autoscaling_configs_for_runners_arm64_medium_dedicated = {
  name               = "runner-arm64-medium-dedicated"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type      = "t4g.medium"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
  warm_pool_activated                   = true
  warm_pool_pool_state                  = "Stopped"
  warm_pool_min_size                    = 1
  warm_pool_max_group_prepared_capacity = 1
}
autoscaling_configs_for_runners_arm64_large_dedicated = {
  name               = "runner-arm64-large-dedicated"
  img_owner          = ["099720109477"]
  image              = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  instance_type      = "t4g.large"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 0
  max_size           = 10
  min_size           = 0
  instance_profile_permissions = [
    "*"
  ]
}
autoscaling_configs_for_runners_arm64_mac = {
  name               = "runners-arm64-mac"
  img_owner          = ["628277914472"]
  image              = ["amzn-ec2-macos-15.6-*-arm64"]
  instance_type      = "mac2.metal"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1f"]
  desired_capacity   = 0
  max_size           = 2
  min_size           = 0
  instance_profile_permissions = [
    "ecr:GetAuthorizationToken",
    "ecr:BatchGetImage",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchCheckLayerAvailability"
  ]
}

#Target Group
tg_port     = 80
tg_protocol = "HTTP"

#s3
storages = [
  {
    name                  = "artifact"
    cloudfront_associated = false
  },
  {
    name                  = "lfs"
    cloudfront_associated = false
  },
  {
    name                  = "uploads"
    cloudfront_associated = false
  },
  {
    name                  = "packages"
    cloudfront_associated = false
  },
  {
    name                  = "backups"
    cloudfront_associated = true
    retention_activated   = true
    retention_days        = 30
  },
  {
    name                  = "cache"
    cloudfront_associated = false
  },
  {
    name                  = "files"
    cloudfront_associated = false
  }
]
tg_matcher_status_code = "200,302,301"

#Route53
route53_domain = "git.your-domain.com.br"
route53 = {
  name = "git.your-domain.com.br"
  type = "A"
  ttl  = 60
}

#LB
lb = {
  internal          = false
  lb_type           = "application"
  logs              = true
  delete_protection = false
}
listener_rule_http = {
  port                 = 80
  protocol             = "HTTP"
  default_action_type  = "redirect"
  redirect_port        = 443
  redirect_protocol    = "HTTPS"
  redirect_status_code = "HTTP_301"
}
listener_rule_https = {
  port                = 443
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2016-08"
  default_action_type = "forward"
}
lb_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
lb_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

#RDS Imports
secret_rds_name = "devops_rds_credentials"
ssm_rds_host    = "/rds/devops/host"
ssm_rds_port    = "/rds/devops/port"

#Certificate
cert_domain_name              = "your-domain.com.br"
cert_domain_alternative_names = ["*.your-domain.com.br"]
cert_record_overwrite         = true
cert_validation_method        = "DNS"
cert_record_ttl               = 60

#SNS
sns_name     = "maintainers"
sns_protocol = "email"
sns_endpoints = [
  "user@your-domain.com.br",
]

#Cloudwatch
cloudwatch_alarm_ec2_ebs = [
  {
    name                = "ebs-dedicated-to-repositories"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "disk_used_percent"
    namespace           = "CWAgent"
    threshold           = 80
    period              = 300
    statistic           = "Average"
    alarm_description   = "EBS disk usage exceeded 80%"
  }
]
cloudwatch_asg_threshold = [5, 8, 10]

kms_keys = [
  {
    key_name = "gitlab-ebs"
    services_access = [
      "autoscaling.amazonaws.com"
    ]
  }
]

#Waf
waf_managed_rule_groups = {
  "CoreRuleSet" = {
    vendor_name = "AWS"
    name        = "AWSManagedRulesCommonRuleSet"
    priority    = 1
    rule_action_override = [
      "SizeRestrictions_QUERYSTRING",
      "SizeRestrictions_BODY",
      "CrossSiteScripting_BODY",
      "GenericRFI_BODY",
      "GenericLFI_BODY",
      "EC2MetaDataSSRF_BODY"
    ]
  },
  "SQLInjectionRuleSet" = {
    vendor_name          = "AWS"
    name                 = "AWSManagedRulesSQLiRuleSet"
    priority             = 2
    rule_action_override = ["SQLi_BODY"]
  },
  "LinuxRuleSet" = {
    vendor_name          = "AWS"
    name                 = "AWSManagedRulesLinuxRuleSet"
    priority             = 3
    rule_action_override = ["LFI_URIPATH", "LFI_HEADER"]
  },
  "IPReputation" = {
    vendor_name = "AWS"
    name        = "AWSManagedRulesAmazonIpReputationList"
    priority    = 4
  },
  "BadInputs" = {
    vendor_name = "AWS"
    name        = "AWSManagedRulesKnownBadInputsRuleSet"
    priority    = 5
  },
  "BotControl" = {
    vendor_name = "AWS"
    name        = "AWSManagedRulesBotControlRuleSet"
    priority    = 6
    rule_action_override = [
      "SignalNonBrowserUserAgent",
      "CategoryHttpLibrary"
    ]
  },
  "AnonymousIpList" = {
    vendor_name = "AWS"
    name        = "AWSManagedRulesAnonymousIpList"
    priority    = 7
  }
}
waf_regional_country_codes = [
  "BR",
  "US"
]
waf_logs_retention_period = 30