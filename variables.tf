variable "account_id" {
  type        = string
  description = "AWS account ID"
}
variable "account_name" {
  type        = string
  description = "AWS account name"
}
variable "account_region" {
  type        = string
  description = "AWS account region"
}
variable "account_project_base_name" {
  type        = string
  description = "Base project name"
}
variable "default_tags" {
  type        = map(string)
  description = "Default tags for resources"
}

#Network definitions
variable "vpc_cidr" {
  type        = string
  description = "Primary VPC CIDR"
}

variable "public_subnets" {
  description = "List of public subnets in the VPC"
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}


variable "private_subnets" {
  description = "List of private subnets in the VPC"
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}

#Network imports
variable "ssm_vpc" {
  type        = string
  description = "SSM Parameter Store name containing the VPC ID"
}
variable "ssm_public_subnets" {
  type        = list(string)
  description = "SSM Parameter Store name containing the public subnet IDs"
}

variable "ssm_private_subnets" {
  type        = list(string)
  description = "SSM Parameter Store name containing the private subnet IDs"
}

#RDS
#RDS
variable "sql_instance_class" {
  type        = string
  description = "RDS instance class"
}
variable "sql_engine" {
  type        = string
  description = "RDS engine"
}
variable "sql_engine_version" {
  type        = string
  description = "RDS engine version"
}
variable "sql_database_name" {
  type        = string
  description = "Database to be created on the RDS"
}
variable "sql_backup_retention_period" {
  type        = number
  description = "RDS backup retention period (days)"
}
variable "sql_allocated_storage" {
  type        = number
  description = "RDS allocated storage size (GB)"
}
variable "rds_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of ingress rules"
}
variable "rds_egress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of egress rules"
}
variable "ec2_sg_gitlab" {
  type        = string
  description = "EC2 security group name"
}

#DNS Imports
variable "domain_name" {
  type        = string
  description = "Route53 domain name to create the certificate"
}
variable "private_zone" {
  type        = bool
  description = "Specifies if the Route53 zone is private or public"
}
variable "record_overwrite" {
  type        = bool
  description = "Allows overwriting the DNS record"
}

variable "record_ttl" {
  type        = number
  description = "TTL for the DNS record"
}

#Certificate
variable "cert_domain_name" {
  type        = string
  description = "Domain name for the certificate"
}
variable "cert_domain_alternative_names" {
  type        = list(string)
  description = "Alternative names for the certificate"
}
variable "cert_record_overwrite" {
  type        = bool
  description = "Overwrite certificate DNS record"
}
variable "cert_validation_method" {
  type        = string
  description = "Certificate validation method"
}
variable "cert_record_ttl" {
  type        = number
  description = "Certificate record TTL"
}

#EBS
variable "ebs_availability_zone" {
  type        = string
  description = "EBS availability zone"
}
variable "ebs_size" {
  type        = number
  description = "EBS volume size (GB)"
}


#Ec2
variable "ec2_name" {
  type        = string
  description = "EC2 instance name"
}
variable "ec2_disk_size" {
  type        = number
  description = "EC2 disk size (GB)"
}
variable "ec2_img_owner" {
  type        = list(string)
  description = "Image owner"
}
variable "ec2_image" {
  type        = list(string)
  description = "EC2 image name"
}
variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "ec2_ip_public" {
  type        = bool
  description = "Specifies if the instance will have a public IP"
}
variable "ec2_egress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of egress rules"
}
variable "ec2_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of ingress rules"
}
variable "object_storage_service_account" {
  type = object({
    name                     = string
    permission_effect        = string
    permissions              = list(string)
    permission_resources_arn = list(string)
  })
}

#Ec2 runner manager
variable "ec2_runner_manager" {
  type = object({
    name          = string
    img_owner     = list(string)
    image         = list(string)
    instance_type = string
    disk_size     = number
    ip_public     = bool
  })
  description = "Values for creating the EC2 Runner Manager (controls creation and removal of EC2 runner instances)"
}
variable "runner_manager_configs" {
  type = object({
    idleCount_amd64 = number
    idleCount_arm64 = number
    idleTime        = string
    maxBuilds       = number
  })
  description = "Runner configurations for the Runner Manager"
}
variable "ec2_runner_manager_egress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of egress rules"
}
variable "ec2_runner_manager_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of ingress rules"
}
variable "ec2_runner_service_account" {
  type = object({
    name                     = string
    permission_effect        = string
    permissions              = list(string)
    permission_resources_arn = list(string)
  })
  description = "Values for creating the EC2 Runner service account"
}
variable "ec2_runner_s3_cache_service_account" {
  type = object({
    name                     = string
    permission_effect        = string
    permissions              = list(string)
    permission_resources_arn = list(string)
  })
}
variable "autoscaling_configs_for_runners_amd64" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_amd64_medium" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_amd64_large" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_amd64_dedicated" {
  type = object({
    name                                  = string
    img_owner                             = list(string)
    image                                 = list(string)
    instance_type                         = string
    availability_zones                    = list(string)
    desired_capacity                      = number
    max_size                              = number
    min_size                              = number
    instance_profile_permissions          = list(string)
    warm_pool_activated                   = bool
    warm_pool_min_size                    = number
    warm_pool_max_group_prepared_capacity = number
    warm_pool_pool_state                  = string
  })
}
variable "autoscaling_configs_for_runners_amd64_medium_dedicated" {
  type = object({
    name                                  = string
    img_owner                             = list(string)
    image                                 = list(string)
    instance_type                         = string
    availability_zones                    = list(string)
    desired_capacity                      = number
    max_size                              = number
    min_size                              = number
    instance_profile_permissions          = list(string)
    warm_pool_activated                   = bool
    warm_pool_min_size                    = number
    warm_pool_max_group_prepared_capacity = number
    warm_pool_pool_state                  = string
  })
}
variable "autoscaling_configs_for_runners_amd64_large_dedicated" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_arm64" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_arm64_medium" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_arm64_large" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_arm64_dedicated" {
  type = object({
    name                                  = string
    img_owner                             = list(string)
    image                                 = list(string)
    instance_type                         = string
    availability_zones                    = list(string)
    desired_capacity                      = number
    max_size                              = number
    min_size                              = number
    instance_profile_permissions          = list(string)
    warm_pool_activated                   = bool
    warm_pool_min_size                    = number
    warm_pool_max_group_prepared_capacity = number
    warm_pool_pool_state                  = string
  })
}
variable "autoscaling_configs_for_runners_arm64_medium_dedicated" {
  type = object({
    name                                  = string
    img_owner                             = list(string)
    image                                 = list(string)
    instance_type                         = string
    availability_zones                    = list(string)
    desired_capacity                      = number
    max_size                              = number
    min_size                              = number
    instance_profile_permissions          = list(string)
    warm_pool_activated                   = bool
    warm_pool_min_size                    = number
    warm_pool_max_group_prepared_capacity = number
    warm_pool_pool_state                  = string
  })
}
variable "autoscaling_configs_for_runners_arm64_large_dedicated" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}
variable "autoscaling_configs_for_runners_arm64_mac" {
  type = object({
    name                         = string
    img_owner                    = list(string)
    image                        = list(string)
    instance_type                = string
    availability_zones           = list(string)
    desired_capacity             = number
    max_size                     = number
    min_size                     = number
    instance_profile_permissions = list(string)
  })
}

#Target Group
variable "tg_protocol" {
  type        = string
  description = "Target group protocol"
}
variable "tg_port" {
  type        = number
  description = "Target group port"
}
variable "tg_matcher_status_code" {
  type        = string
  description = "Status codes to mark the target as healthy"
}

#s3
variable "storages" {
  type = list(object({
    name                  = string
    cloudfront_associated = bool
    retention_activated   = optional(bool)
    retention_days        = optional(number)
  }))
  description = "List of storages"
}

#Route53
variable "route53_domain" {
  type        = string
  description = "Route53 domain name"
}
variable "route53" {
  type = object({
    name = string
    type = string
    ttl  = number
  })
  description = "DNS record configurations in Route53"
}

#LB
variable "lb" {
  type = object({
    internal          = bool
    lb_type           = string
    logs              = bool
    delete_protection = bool
  })
}
variable "lb_egress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of egress rules"
}
variable "lb_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  description = "List of ingress rules"
}

variable "listener_rule_http" {
  type = object({
    port                 = number
    protocol             = string
    default_action_type  = string
    redirect_port        = number
    redirect_protocol    = string
    redirect_status_code = string
  })
}

variable "listener_rule_https" {
  type = object({
    port                = number
    protocol            = string
    ssl_policy          = string
    default_action_type = string
  })
}

#RDS Imports
variable "secret_rds_name" {
  type        = string
  description = "Name of the secret with GitLab user credentials"
}
variable "ssm_rds_host" {
  type        = string
  description = "RDS host"
}
variable "ssm_rds_port" {
  type        = string
  description = "RDS port"
}

#Clouwatch Alarms + SNS topic Subscription
variable "sns_name" {
  type        = string
  description = "Name of the SNS topic"
}
variable "sns_protocol" {
  type        = string
  description = "Subscription protocol for the SNS topic"
}

variable "sns_endpoints" {
  type        = list(string)
  description = "Endpoints to subscribe to the SNS topic"
}

variable "cloudwatch_alarm_ec2_ebs" {
  type = list(object({
    name                = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    threshold           = number
    period              = number
    statistic           = string
    alarm_description   = string
  }))
  description = "CloudWatch alarm for EC2/EBS host"
}
variable "cloudwatch_asg_threshold" {
  type        = list(number)
  description = "List of thresholds for CloudWatch ASG alarm"
}

#KMS
variable "kms_keys" {
  type = list(object({
    key_name          = string
    services_access   = list(string)
    key_usage         = optional(string)
    kms_key_enabled   = optional(bool)
    multi_region      = optional(bool)
    key_rotation      = optional(bool)
    key_rotation_days = optional(number)
  }))
}

#WAF
variable "waf_managed_rule_groups" {
  type = map(object({
    vendor_name          = string
    name                 = string
    priority             = number
    rule_action_override = optional(list(string))
  }))
  description = "List of managed rule groups for the WAF"
}
variable "waf_regional_country_codes" {
  type        = list(string)
  description = "List of country codes for regional WAF rules"
}
variable "waf_logs_retention_period" {
  type        = number
  description = "WAF logs retention period (days)"
}