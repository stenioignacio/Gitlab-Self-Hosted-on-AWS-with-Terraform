locals {
  #Gitlab root password
  root_password = jsondecode(file("./root.json"))["root"]

  #Access keys for SES
  ses_credentials = jsondecode(file("./ses.json"))

  #Runners token
  runner_manager_token                = jsondecode(file("./runner_manager_token.json"))["token"]
  runner_token_amd64                  = jsondecode(file("./runners_token_amd64.json"))["token"]
  runner_token_arm64                  = jsondecode(file("./runners_token_arm64.json"))["token"]
  runner_token_amd64_dedicated        = jsondecode(file("./runners_token_amd64_dedicated.json"))["token"]
  runner_token_arm64_dedicated        = jsondecode(file("./runners_token_arm64_dedicated.json"))["token"]
  runner_token_amd64_medium           = jsondecode(file("./runners_token_amd64_medium.json"))["token"]
  runner_token_arm64_medium           = jsondecode(file("./runners_token_arm64_medium.json"))["token"]
  runner_token_amd64_medium_dedicated = jsondecode(file("./runners_token_amd64_medium_dedicated.json"))["token"]
  runner_token_arm64_medium_dedicated = jsondecode(file("./runners_token_arm64_medium_dedicated.json"))["token"]
  runner_token_amd64_large            = jsondecode(file("./runners_token_amd64_large.json"))["token"]
  runner_token_arm64_large            = jsondecode(file("./runners_token_arm64_large.json"))["token"]
  runner_token_amd64_large_dedicated  = jsondecode(file("./runners_token_amd64_large_dedicated.json"))["token"]
  runner_token_arm64_large_dedicated  = jsondecode(file("./runners_token_arm64_large_dedicated.json"))["token"]
  runner_token_arm64_mac              = jsondecode(file("./runners_token_arm64_mac.json"))["token"]

  #Configs - optional
  bitbucket = jsondecode(file("./bitbucket.json"))

  #RDS Gitlab secrets
  secret_map = jsondecode(data.aws_secretsmanager_secret_version.user_and_password.secret_string)

  gitlab_rds_username = local.secret_map["username"]
  gitlab_rds_password = local.secret_map["password"]

  #SSO
  sso_credentials = jsondecode(file("./sso_credentials.json"))
}

module "json_file_secrets" {
  source = "./modules/secret_manager"

  name = "git_local_files_secrets"
  values = {
    root                                 = local.root_password
    ses_access                           = local.ses_credentials["access_key"]
    ses_secret                           = local.ses_credentials["secret_key"]
    runner_manager_token                 = local.runner_manager_token
    runners_token_amd64                  = local.runner_token_amd64
    runners_token_arm64                  = local.runner_token_arm64
    runners_token_amd64_dedicated        = local.runner_token_amd64_dedicated
    runners_token_arm64_dedicated        = local.runner_token_arm64_dedicated
    runners_token_amd64_medium           = local.runner_token_amd64_medium
    runners_token_arm64_medium           = local.runner_token_arm64_medium
    runners_token_amd64_medium_dedicated = local.runner_token_amd64_medium_dedicated
    runners_token_arm64_medium_dedicated = local.runner_token_arm64_medium_dedicated
    runners_token_amd64_large            = local.runner_token_amd64_large
    runners_token_arm64_large            = local.runner_token_arm64_large
    runners_token_amd64_large_dedicated  = local.runner_token_amd64_large_dedicated
    runners_token_arm64_large_dedicated  = local.runner_token_arm64_large_dedicated
    runners_token_arm64_mac              = local.runner_token_arm64_mac
    bitbucket_bitbucket_app_key          = local.bitbucket["bitbucket_app_key"]
    bitbucket_bitbucket_app_secret       = local.bitbucket["bitbucket_app_secret"]
    sso_credentials_idp_cert             = local.sso_credentials["idp_cert"]
    sso_credentials_idp_url              = local.sso_credentials["idp_url"]
  }
}