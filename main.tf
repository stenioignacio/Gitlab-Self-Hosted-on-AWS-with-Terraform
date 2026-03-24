#Network confugurations
module "vpc" {
  source = "./modules/vpc"

  account_project_base_name = var.account_project_base_name
  vpc_cidr                  = var.vpc_cidr
}

module "private_subnets" {
  source = "./modules/private_subnet"

  account_project_base_name = var.account_project_base_name

  vpc_id         = module.vpc.vpc_id
  vpc_cidr       = module.vpc.vpc_cidr
  subnets        = var.private_subnets
  public_subnets = module.public_subnets.subnet_id

  depends_on = [module.vpc]
}

module "public_subnets" {
  source = "./modules/public_subnet"

  account_project_base_name = var.account_project_base_name

  vpc_id              = module.vpc.vpc_id
  subnets             = var.public_subnets
  internet_gateway_id = module.vpc.internet_gateway_id

  depends_on = [module.vpc]
}

module "sg_rds" {
  source = "./modules/security_group"

  name                      = "${var.account_project_base_name}-rds"
  account_project_base_name = var.account_project_base_name
  vpc_id                    = module.vpc.vpc_id
  ingress_rules = concat([
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = data.aws_ssm_parameter.gitlab_sg.value
    }
  ], var.rds_ingress_rules)
  egress_rules = var.rds_egress_rules
}

module "rds" {
  source = "./modules/rds"

  account_project_base_name = var.account_project_base_name

  private_subnets         = module.private_subnets.subnet_id
  engine                  = var.sql_engine
  engine_version          = var.sql_engine_version
  db_name                 = var.sql_database_name
  instance_class          = var.sql_instance_class
  backup_retention_period = var.sql_backup_retention_period
  allocated_storage       = var.sql_allocated_storage
  security_group          = [module.sg_rds.security_group_id]

  depends_on = [module.sg_rds]
}

module "waf" {
  source = "./modules/waf"

  account_project_base_name   = var.account_project_base_name
  resource_association_arn    = [module.lb.arn]
  regional_country_codes_rule = var.waf_regional_country_codes
  managed_rule_groups         = var.waf_managed_rule_groups
  logs_retention_period       = var.waf_logs_retention_period

  depends_on = [module.lb]
}

# Gitlab Host EBS dedicated to repositorys
module "ebs" {
  source = "./modules/ebs"

  account_project_base_name = var.account_project_base_name
  size                      = var.ebs_size
  availability_zone         = var.ebs_availability_zone
  instance_id               = module.ec2.id
  kms_key_id                = module.kms[0].key_arn
}

# Security Group with olny necessary permissions
module "sg_ec2" {
  source = "./modules/security_group"

  name                      = "${var.account_project_base_name}-host"
  account_project_base_name = var.account_project_base_name
  vpc_id                    = data.aws_ssm_parameter.vpc.value
  ingress_rules             = var.ec2_ingress_rules
  egress_rules              = var.ec2_egress_rules
}

# Service Account to access s3 with "gitlab-secret.json"
module "object_storage_service_account" {
  source = "./modules/iam_service_account"

  name                     = var.object_storage_service_account.name
  permission_effect        = var.object_storage_service_account.permission_effect
  permissions              = var.object_storage_service_account.permissions
  permission_resources_arn = var.object_storage_service_account.permission_resources_arn
}

# Ec2 Gitlab Host
module "ec2" {
  source = "./modules/ec2"

  name                      = var.ec2_name
  account_project_base_name = var.account_project_base_name
  img_owner                 = var.ec2_img_owner
  image                     = var.ec2_image
  subnet_id                 = data.aws_ssm_parameter.private_subnets[1].value
  disk_size                 = var.ec2_disk_size
  ip_public                 = var.ec2_ip_public
  instance_type             = var.ec2_instance_type
  security_group_ids        = [module.sg_ec2.security_group_id]
  cw_sns_topic_arn          = module.sns.arn
  user_data_script = templatefile("./templates_tpl/user_data.tpl", {
    dns_record    = var.route53.name
    root_password = local.root_password

    db_host = data.aws_ssm_parameter.rds_host.value
    db_port = data.aws_ssm_parameter.rds_port.value
    db_user = local.gitlab_rds_username
    db_pass = local.gitlab_rds_password

    aws_region      = module.s3[0].region
    artifact_bucket = module.s3[0].name
    lfs_bucket      = module.s3[1].name
    uploads_bucket  = module.s3[2].name
    packages_bucket = module.s3[3].name
    backup_bucket   = module.s3[4].name

    ses_access_key = local.ses_credentials.access_key
    ses_secret_key = local.ses_credentials.secret_key
    s3_access_key  = module.object_storage_service_account.user_access_key
    s3_secret_key  = module.object_storage_service_account.user_secret_key

    #Integrations
    bitbucket_app_key    = local.bitbucket.bitbucket_app_key
    bitbucket_app_secret = local.bitbucket.bitbucket_app_secret

    #SSO
    idp_cert = local.sso_credentials.idp_cert
    idp_url  = local.sso_credentials.idp_url
  })

  depends_on = [
    local.root_password,
    data.aws_ssm_parameter.private_subnets,
    module.s3,
    data.aws_ssm_parameter.rds_host,
    data.aws_ssm_parameter.rds_port,
    module.sg_ec2,
    local.bitbucket
  ]
}

# Gitlab Runners Security Group
module "sg_ec2_runners" {
  source = "./modules/security_group"

  name                      = "${var.account_project_base_name}-runners"
  account_project_base_name = var.account_project_base_name
  vpc_id                    = data.aws_ssm_parameter.vpc.value
  ingress_rules             = var.ec2_runner_manager_ingress_rules
  egress_rules              = var.ec2_runner_manager_egress_rules
}

# Gitlab Runner Manager Security Group
module "sg_ec2_runner_manager" {
  source = "./modules/security_group"

  name                      = "${var.account_project_base_name}-runner-manager"
  account_project_base_name = var.account_project_base_name
  vpc_id                    = data.aws_ssm_parameter.vpc.value
  ingress_rules             = var.ec2_runner_manager_ingress_rules
  egress_rules              = var.ec2_runner_manager_egress_rules
}

# Auto Scaling Groups - Runners
module "asg_runners_amd64" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_amd64.name
  img_owner                    = var.autoscaling_configs_for_runners_amd64.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_amd64.image
  instance_type                = var.autoscaling_configs_for_runners_amd64.instance_type
  max_size                     = var.autoscaling_configs_for_runners_amd64.max_size
  min_size                     = var.autoscaling_configs_for_runners_amd64.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_amd64.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_amd64.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_amd64.tpl", {}))
  spot_instance                = true
  instance_profile_permissions = var.autoscaling_configs_for_runners_amd64.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_amd64]
}
module "asg_runners_amd64_medium" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_amd64_medium.name
  img_owner                    = var.autoscaling_configs_for_runners_amd64_medium.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_amd64_medium.image
  instance_type                = var.autoscaling_configs_for_runners_amd64_medium.instance_type
  max_size                     = var.autoscaling_configs_for_runners_amd64_medium.max_size
  min_size                     = var.autoscaling_configs_for_runners_amd64_medium.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_amd64_medium.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_amd64_medium.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_amd64.tpl", {}))
  spot_instance                = true
  instance_profile_permissions = var.autoscaling_configs_for_runners_amd64_medium.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_amd64]
}
module "asg_runners_amd64_large" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_amd64_large.name
  img_owner                    = var.autoscaling_configs_for_runners_amd64_large.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_amd64_large.image
  instance_type                = var.autoscaling_configs_for_runners_amd64_large.instance_type
  max_size                     = var.autoscaling_configs_for_runners_amd64_large.max_size
  min_size                     = var.autoscaling_configs_for_runners_amd64_large.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_amd64_large.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_amd64_large.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_amd64.tpl", {}))
  spot_instance                = true
  instance_profile_permissions = var.autoscaling_configs_for_runners_amd64_large.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_amd64]
}

module "asg_runners_amd64_dedicated" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_amd64_dedicated.name
  img_owner                    = var.autoscaling_configs_for_runners_amd64_dedicated.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_amd64_dedicated.image
  instance_type                = var.autoscaling_configs_for_runners_amd64_dedicated.instance_type
  max_size                     = var.autoscaling_configs_for_runners_amd64_dedicated.max_size
  min_size                     = var.autoscaling_configs_for_runners_amd64_dedicated.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_amd64_dedicated.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_amd64_dedicated.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_amd64.tpl", {}))
  spot_instance                = false
  instance_profile_permissions = var.autoscaling_configs_for_runners_amd64_dedicated.instance_profile_permissions

  warm_pool_activated                   = var.autoscaling_configs_for_runners_amd64_dedicated.warm_pool_activated
  warm_pool_min_size                    = var.autoscaling_configs_for_runners_amd64_dedicated.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.autoscaling_configs_for_runners_amd64_dedicated.warm_pool_max_group_prepared_capacity
  warm_pool_pool_state                  = var.autoscaling_configs_for_runners_amd64_dedicated.warm_pool_pool_state

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_amd64]
}
module "asg_runners_amd64_medium_dedicated" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_amd64_medium_dedicated.name
  img_owner                    = var.autoscaling_configs_for_runners_amd64_medium_dedicated.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_amd64_medium_dedicated.image
  instance_type                = var.autoscaling_configs_for_runners_amd64_medium_dedicated.instance_type
  max_size                     = var.autoscaling_configs_for_runners_amd64_medium_dedicated.max_size
  min_size                     = var.autoscaling_configs_for_runners_amd64_medium_dedicated.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_amd64_medium_dedicated.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_amd64_medium_dedicated.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_amd64.tpl", {}))
  spot_instance                = false
  instance_profile_permissions = var.autoscaling_configs_for_runners_amd64_medium_dedicated.instance_profile_permissions

  warm_pool_activated                   = var.autoscaling_configs_for_runners_amd64_medium_dedicated.warm_pool_activated
  warm_pool_min_size                    = var.autoscaling_configs_for_runners_amd64_medium_dedicated.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.autoscaling_configs_for_runners_amd64_medium_dedicated.warm_pool_max_group_prepared_capacity
  warm_pool_pool_state                  = var.autoscaling_configs_for_runners_amd64_medium_dedicated.warm_pool_pool_state

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_amd64]
}
module "asg_runners_amd64_large_dedicated" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_amd64_large_dedicated.name
  img_owner                    = var.autoscaling_configs_for_runners_amd64_large_dedicated.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_amd64_large_dedicated.image
  instance_type                = var.autoscaling_configs_for_runners_amd64_large_dedicated.instance_type
  max_size                     = var.autoscaling_configs_for_runners_amd64_large_dedicated.max_size
  min_size                     = var.autoscaling_configs_for_runners_amd64_large_dedicated.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_amd64_large_dedicated.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_amd64_large_dedicated.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_amd64.tpl", {}))
  spot_instance                = false
  instance_profile_permissions = var.autoscaling_configs_for_runners_amd64_large_dedicated.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_amd64]
}

module "asg_runners_arm64" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_arm64.name
  img_owner                    = var.autoscaling_configs_for_runners_arm64.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_arm64.image
  instance_type                = var.autoscaling_configs_for_runners_arm64.instance_type
  max_size                     = var.autoscaling_configs_for_runners_arm64.max_size
  min_size                     = var.autoscaling_configs_for_runners_arm64.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_arm64.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_arm64.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_arm64.tpl", {}))
  spot_instance                = true
  instance_profile_permissions = var.autoscaling_configs_for_runners_arm64.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_arm64]
}

module "asg_runners_arm64_medium" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_arm64_medium.name
  img_owner                    = var.autoscaling_configs_for_runners_arm64_medium.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_arm64_medium.image
  instance_type                = var.autoscaling_configs_for_runners_arm64_medium.instance_type
  max_size                     = var.autoscaling_configs_for_runners_arm64_medium.max_size
  min_size                     = var.autoscaling_configs_for_runners_arm64_medium.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_arm64_medium.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_arm64_medium.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_arm64.tpl", {}))
  spot_instance                = true
  instance_profile_permissions = var.autoscaling_configs_for_runners_arm64_medium.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_arm64]
}

module "asg_runners_arm64_large" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_arm64_large.name
  img_owner                    = var.autoscaling_configs_for_runners_arm64_large.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_arm64_large.image
  instance_type                = var.autoscaling_configs_for_runners_arm64_large.instance_type
  max_size                     = var.autoscaling_configs_for_runners_arm64_large.max_size
  min_size                     = var.autoscaling_configs_for_runners_arm64_large.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_arm64_large.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_arm64_large.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_arm64.tpl", {}))
  spot_instance                = true
  instance_profile_permissions = var.autoscaling_configs_for_runners_arm64_large.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_arm64]
}


module "asg_runners_arm64_dedicated" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_arm64_dedicated.name
  img_owner                    = var.autoscaling_configs_for_runners_arm64_dedicated.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_arm64_dedicated.image
  instance_type                = var.autoscaling_configs_for_runners_arm64_dedicated.instance_type
  max_size                     = var.autoscaling_configs_for_runners_arm64_dedicated.max_size
  min_size                     = var.autoscaling_configs_for_runners_arm64_dedicated.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_arm64_dedicated.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_arm64_dedicated.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_arm64.tpl", {}))
  spot_instance                = false
  instance_profile_permissions = var.autoscaling_configs_for_runners_arm64.instance_profile_permissions

  warm_pool_activated                   = var.autoscaling_configs_for_runners_arm64_dedicated.warm_pool_activated
  warm_pool_min_size                    = var.autoscaling_configs_for_runners_arm64_dedicated.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.autoscaling_configs_for_runners_arm64_dedicated.warm_pool_max_group_prepared_capacity
  warm_pool_pool_state                  = var.autoscaling_configs_for_runners_arm64_dedicated.warm_pool_pool_state

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_arm64]
}

module "asg_runners_arm64_medium_dedicated" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_arm64_medium_dedicated.name
  img_owner                    = var.autoscaling_configs_for_runners_arm64_medium_dedicated.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_arm64_medium_dedicated.image
  instance_type                = var.autoscaling_configs_for_runners_arm64_medium_dedicated.instance_type
  max_size                     = var.autoscaling_configs_for_runners_arm64_medium_dedicated.max_size
  min_size                     = var.autoscaling_configs_for_runners_arm64_medium_dedicated.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_arm64_medium_dedicated.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_arm64_medium_dedicated.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_arm64.tpl", {}))
  spot_instance                = false
  instance_profile_permissions = var.autoscaling_configs_for_runners_arm64_medium.instance_profile_permissions

  warm_pool_activated                   = var.autoscaling_configs_for_runners_arm64_medium_dedicated.warm_pool_activated
  warm_pool_min_size                    = var.autoscaling_configs_for_runners_arm64_medium_dedicated.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.autoscaling_configs_for_runners_arm64_medium_dedicated.warm_pool_max_group_prepared_capacity
  warm_pool_pool_state                  = var.autoscaling_configs_for_runners_arm64_medium_dedicated.warm_pool_pool_state

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_arm64]
}

module "asg_runners_arm64_large_dedicated" {
  source = "./modules/auto_scaling_group"

  account_project_base_name = var.account_project_base_name

  name                         = var.autoscaling_configs_for_runners_arm64_large_dedicated.name
  img_owner                    = var.autoscaling_configs_for_runners_arm64_large_dedicated.img_owner
  subnets                      = data.aws_ssm_parameter.private_subnets[*].value
  image                        = var.autoscaling_configs_for_runners_arm64_large_dedicated.image
  instance_type                = var.autoscaling_configs_for_runners_arm64_large_dedicated.instance_type
  max_size                     = var.autoscaling_configs_for_runners_arm64_large_dedicated.max_size
  min_size                     = var.autoscaling_configs_for_runners_arm64_large_dedicated.min_size
  security_group_ids           = [module.sg_ec2_runners.security_group_id]
  desired_capacity             = var.autoscaling_configs_for_runners_arm64_large_dedicated.desired_capacity
  availability_zones           = var.autoscaling_configs_for_runners_arm64_large_dedicated.availability_zones
  user_data_script             = base64encode(templatefile("./templates_tpl/runners_arm64.tpl", {}))
  spot_instance                = false
  instance_profile_permissions = var.autoscaling_configs_for_runners_arm64_large.instance_profile_permissions

  threshold     = var.cloudwatch_asg_threshold
  sns_topic_arn = module.sns.arn

  depends_on = [local.runner_token_arm64]
}
#This ASG is to create a mac runners, uncomment than to use! Look you need to add on runner_manager.tpl script to enable than!
# module "asg_runners_arm64_mac" {
#   source = "./modules/auto_scaling_group"

#   account_project_base_name = var.account_project_base_name

#   name               = var.autoscaling_configs_for_runners_arm64_mac.name
#   img_owner          = var.autoscaling_configs_for_runners_arm64_mac.img_owner
#   subnets            = data.aws_ssm_parameter.private_subnets[*].value
#   image              = var.autoscaling_configs_for_runners_arm64_mac.image
#   instance_type      = var.autoscaling_configs_for_runners_arm64_mac.instance_type
#   max_size           = var.autoscaling_configs_for_runners_arm64_mac.max_size
#   min_size           = var.autoscaling_configs_for_runners_arm64_mac.min_size
#   security_group_ids = [module.sg_ec2_runners.security_group_id]
#   desired_capacity   = var.autoscaling_configs_for_runners_arm64_mac.desired_capacity
#   availability_zones = var.autoscaling_configs_for_runners_arm64_mac.availability_zones
#   user_data_script = base64encode(templatefile("./templates_tpl/runners_arm64_mac.tpl", {
#     dns_record   = var.route53.name
#     runner_token = local.runner_token_arm64_mac
#     runner_name  = var.ec2_runner_manager.name
#   }))
#   spot_instance = true

#   depends_on = [ local.runner_token_arm64_mac ]
# }

module "ec2_runner_manager" {
  source = "./modules/ec2"

  name                      = var.ec2_runner_manager.name
  account_project_base_name = var.account_project_base_name
  img_owner                 = var.ec2_runner_manager.img_owner
  image                     = var.ec2_runner_manager.image
  subnet_id                 = data.aws_ssm_parameter.private_subnets[1].value
  disk_size                 = var.ec2_runner_manager.disk_size
  ip_public                 = var.ec2_runner_manager.ip_public
  instance_type             = var.ec2_runner_manager.instance_type
  security_group_ids        = [module.sg_ec2_runner_manager.security_group_id]
  cw_sns_topic_arn          = module.sns.arn
  aditional_role_permissions = [
    "ec2:*",
    "autoscaling:*",
    "ec2-instance-connect:SendSSHPublicKey",
    "iam:PassRole",
    "cloudwatch:PutMetricData",
    "cloudwatch:GetMetricStatistics",
    "cloudwatch:ListMetrics",
    "ssm:SendCommand",
    "ssm:GetCommandInvocation",
    "ssm:DescribeInstanceInformation",
    "ssm:ListCommands",
    "ssm:ListCommandInvocations"
  ]
  user_data_script = templatefile("./templates_tpl/runner_manager.tpl", {
    runner_name        = var.ec2_runner_manager.name
    runner_token       = local.runner_manager_token
    dns_record         = var.route53.name
    gitlab_internal_ip = module.ec2.private_ip

    # Runners ingress
    #Spot
    runner_name_amd64  = module.asg_runners_amd64.name
    runner_token_amd64 = local.runner_token_amd64
    asg_name_amd64     = module.asg_runners_amd64.name
    runner_name_arm64  = module.asg_runners_arm64.name
    runner_token_arm64 = local.runner_token_arm64
    asg_name_arm64     = module.asg_runners_arm64.name

    runner_name_amd64_medium  = module.asg_runners_amd64_medium.name
    runner_token_amd64_medium = local.runner_token_amd64_medium
    asg_name_amd64_medium     = module.asg_runners_amd64_medium.name
    runner_name_arm64_medium  = module.asg_runners_arm64_medium.name
    runner_token_arm64_medium = local.runner_token_arm64_medium
    asg_name_arm64_medium     = module.asg_runners_arm64_medium.name

    runner_name_amd64_large  = module.asg_runners_amd64_large.name
    runner_token_amd64_large = local.runner_token_amd64_large
    asg_name_amd64_large     = module.asg_runners_amd64_large.name
    runner_name_arm64_large  = module.asg_runners_arm64_large.name
    runner_token_arm64_large = local.runner_token_arm64_large
    asg_name_arm64_large     = module.asg_runners_arm64_large.name

    #Dedicated
    #Arm64
    runner_name_arm64_dedicated  = module.asg_runners_arm64_dedicated.name
    asg_name_arm64_dedicated     = module.asg_runners_arm64_dedicated.name
    runner_token_arm64_dedicated = local.runner_token_arm64_dedicated

    runner_name_arm64_medium_dedicated  = module.asg_runners_arm64_medium_dedicated.name
    asg_name_arm64_medium_dedicated     = module.asg_runners_arm64_medium_dedicated.name
    runner_token_arm64_medium_dedicated = local.runner_token_arm64_medium_dedicated

    runner_name_arm64_large_dedicated  = module.asg_runners_arm64_large_dedicated.name
    asg_name_arm64_large_dedicated     = module.asg_runners_arm64_large_dedicated.name
    runner_token_arm64_large_dedicated = local.runner_token_arm64_large_dedicated

    #Amd64
    runner_name_amd64_dedicated  = module.asg_runners_amd64_dedicated.name
    asg_name_amd64_dedicated     = module.asg_runners_amd64_dedicated.name
    runner_token_amd64_dedicated = local.runner_token_amd64_dedicated

    runner_name_amd64_medium_dedicated  = module.asg_runners_amd64_medium_dedicated.name
    asg_name_amd64_medium_dedicated     = module.asg_runners_amd64_medium_dedicated.name
    runner_token_amd64_medium_dedicated = local.runner_token_amd64_medium_dedicated

    runner_name_amd64_large_dedicated  = module.asg_runners_amd64_large_dedicated.name
    asg_name_amd64_large_dedicated     = module.asg_runners_amd64_large_dedicated.name
    runner_token_amd64_large_dedicated = local.runner_token_amd64_large_dedicated

    # runner_name_arm64_mac  = module.asg_runners_arm64_mac.name
    # runner_token_arm64_mac = local.runner_token_arm64_mac
    # asg_name_arm64_mac = module.asg_runners_arm64_mac.name

    #Runners.Machine
    #AMD64
    idleCount_arm64 = var.runner_manager_configs.idleCount_arm64

    #ARM64
    idleCount_amd64 = var.runner_manager_configs.idleCount_amd64

    idleTime  = var.runner_manager_configs.idleTime
    maxBuilds = var.runner_manager_configs.maxBuilds
  })

  depends_on = [
    # module.ec2, 
    module.sg_ec2_runner_manager,
    module.sg_ec2_runners,
    local.runner_manager_token,
    local.runner_token_amd64,
    local.runner_token_arm64,
    local.runner_token_arm64_mac
  ]
}

module "ec2_instance_connector_endpoint" {
  source = "./modules/instance_connector_endpoint"

  account_project_base_name = var.account_project_base_name
  subnet_id                 = module.ec2.subnet_id
}

# Load balancer
module "target_group_lb_tcp" {
  source = "./modules/target_group"

  account_project_base_name = var.account_project_base_name
  vpc_id                    = data.aws_ssm_parameter.vpc.value
  protocol                  = var.tg_protocol
  port                      = var.tg_port
  target_id                 = module.ec2.id
  matcher_status_code       = var.tg_matcher_status_code
}

module "sg_lb" {
  source = "./modules/security_group"

  name                      = "${var.account_project_base_name}-lb"
  account_project_base_name = var.account_project_base_name
  vpc_id                    = data.aws_ssm_parameter.vpc.value
  ingress_rules             = var.lb_ingress_rules
  egress_rules              = var.lb_egress_rules
}

module "lb" {
  source = "./modules/load_balancer"

  account_project_base_name = var.account_project_base_name
  subnets                   = data.aws_ssm_parameter.public_subnets[*].value
  internal                  = var.lb.internal
  load_balancer_type        = var.lb.lb_type
  security_group            = [module.sg_lb.security_group_id]
  logs                      = var.lb.logs
  delete_protection         = var.lb.delete_protection

  #Listener rules
  port_http                = var.listener_rule_http.port
  protocol_http            = var.listener_rule_http.protocol
  default_action_type_http = var.listener_rule_http.default_action_type
  redirect_port            = var.listener_rule_http.redirect_port
  redirect_protocol        = var.listener_rule_http.redirect_protocol
  redirect_status_code     = var.listener_rule_http.redirect_status_code
  tg_arn                   = module.target_group_lb_tcp.arn

  port_https                = var.listener_rule_https.port
  protocol_https            = var.listener_rule_https.protocol
  ssl_policy_https          = var.listener_rule_https.ssl_policy
  certificate_arn           = module.certificate.arn
  default_action_type_https = var.listener_rule_https.default_action_type

  depends_on = [module.certificate, module.target_group_lb_tcp]
}

module "certificate" {
  source = "./modules/certificate"

  account_project_base_name = var.account_project_base_name

  domain_name              = var.cert_domain_name
  domain_alternative_names = var.cert_domain_alternative_names
  record_overwrite         = var.cert_record_overwrite
  validation_method        = var.cert_validation_method
  record_ttl               = var.cert_record_ttl
}

module "s3" {
  source = "./modules/s3"

  count = length(var.storages)

  region                    = var.account_region
  account_project_base_name = var.account_project_base_name
  name                      = var.storages[count.index].name
  retention_period_active   = var.storages[count.index].retention_activated
  retention_days            = var.storages[count.index].retention_days
}

module "sns" {
  source = "./modules/sns"

  account_project_base_name = var.account_project_base_name
  name                      = var.sns_name
  protocol                  = var.sns_protocol
  endpoint                  = var.sns_endpoints
}

module "cloudwatch_alarm_ec2_host_ebs" {
  source = "./modules/cloudwatch_alarm"

  count = length(var.cloudwatch_alarm_ec2_ebs)

  name                = "${var.cloudwatch_alarm_ec2_ebs[count.index].name}-${module.ec2.name}"
  comparison_operator = var.cloudwatch_alarm_ec2_ebs[count.index].comparison_operator
  evaluation_periods  = var.cloudwatch_alarm_ec2_ebs[count.index].evaluation_periods
  metric_name         = var.cloudwatch_alarm_ec2_ebs[count.index].metric_name
  namespace           = var.cloudwatch_alarm_ec2_ebs[count.index].namespace
  threshold           = var.cloudwatch_alarm_ec2_ebs[count.index].threshold
  period              = var.cloudwatch_alarm_ec2_ebs[count.index].period
  statistic           = var.cloudwatch_alarm_ec2_ebs[count.index].statistic
  dimension = {
    InstanceId = module.ec2.id
    path       = "/var/opt/gitlab"
    device     = "nvme1n1"
    fstype     = "ext4"
  }

  alarm_description = var.cloudwatch_alarm_ec2_ebs[count.index].alarm_description

  sns_topic_arn = module.sns.arn
}

module "kms" {
  source = "./modules/kms"

  count = length(var.kms_keys)

  account_project_base_name   = var.account_project_base_name
  kms_alias_name              = var.kms_keys[count.index].key_name
  services_with_access_to_key = var.kms_keys[count.index].services_access
}

module "private_route53" {
  source = "./modules/route53"

  vpc_id = data.aws_ssm_parameter.vpc.value
  name   = var.route53_domain
  records = [
    {
      name    = var.route53.name
      type    = var.route53.type
      ttl     = var.route53.ttl
      records = flatten([module.lb.alb_private_ips])
    }
  ]
}

module "public_route53" {
  source = "./modules/route53"

  vpc_id = data.aws_ssm_parameter.vpc.value
  name   = var.route53_domain
  records = [
    {
      name    = var.route53.name
      type    = var.route53.type
      ttl     = var.route53.ttl
      records = flatten([module.lb.dns_name])
    }
  ]
}