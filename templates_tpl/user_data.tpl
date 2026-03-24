#!/bin/bash

sudo usermod -a -G admin ubuntu

set -x

# Install AWS CLI v2 on Ubuntu
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
sudo apt-get install unzip
sudo unzip awscliv2.zip
sudo ./aws/install --update
aws --version

# Add permissions if you set-up hardening before installing GitLab
sudo chown git:git /opt/gitlab/embedded/service/gitlab-rails/log/*.log
sudo chown git:git /var/log/gitlab/puma/*.log
sudo chown git:git /var/log/gitlab/puma

# Install Gitlab
sudo apt update -y

sudo apt remove -y curl-minimal || true

sudo apt install -y curl policycoreutils-python-utils openssh-server openssh-clients perl

sudo systemctl enable --now ssh

curl "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh" | sudo bash

# Install GitLab without automatic configuration
sudo EXTERNAL_URL="https://${dns_record}" apt install -y gitlab-ce

# Stop GitLab before configuration
sudo gitlab-ctl stop

# Mount the EBS volume
if ! sudo file -s /dev/nvme1n1 | grep -q 'ext4'; then
  sudo mkfs.ext4 /dev/nvme1n1
fi
sudo mount /dev/nvme1n1 /var/opt/gitlab
echo "/dev/nvme1n1 /var/opt/gitlab ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
sudo chown -R git:git /var/opt/gitlab

chown -R git:git /var/opt/gitlab
chown -R gitlab-psql:gitlab-psql /var/opt/gitlab/postgresql
chown -R git:git /var/opt/gitlab/redis
chown -R git:git /var/opt/gitlab/prometheus
chmod -R 700 /var/opt/gitlab

sudo bash -c 'cat <<EOF >> /etc/gitlab/gitlab.rb
gitlab_rails["initial_root_password"] = "'${root_password}'"
letsencrypt["enable"] = false
nginx["listen_port"] = 80
nginx["ssl_certificate"] = nil
nginx["ssl_certificate_key"] = nil
nginx["listen_https"] = false
nginx["redirect_http_to_https"] = false
nginx["proxy_set_headers"] = {"X-Forwarded-Proto" => "https","X-Forwarded-Ssl" => "on","X-Forwarded-Host" => "'${dns_record}'"}
gitlab_rails["smtp_enable"] = true
gitlab_rails["smtp_address"] = "email-smtp.us-east-1.amazonaws.com"
gitlab_rails["smtp_port"] = 587
gitlab_rails["smtp_user_name"] = "${ses_access_key}"
gitlab_rails["smtp_password"] = "${ses_secret_key}"
gitlab_rails["smtp_domain"] = "your-domain.com.br"
gitlab_rails["smtp_authentication"] = "login"
gitlab_rails["smtp_enable_starttls_auto"] = true
gitlab_rails["gitlab_email_from"] = "git@your-domain.com.br"
gitlab_rails["gitlab_email_display_name"] = "Git My Company"
gitlab_rails["gitlab_email_reply_to"] = "git@your-domain.com.br"

gitlab_rails["db_adapter"] = "postgresql"
gitlab_rails["db_encoding"] = "utf8"
gitlab_rails["db_host"] = "'${db_host}'"
gitlab_rails["db_port"] = '${db_port}'
gitlab_rails["db_username"] = "'${db_user}'"
gitlab_rails["db_password"] = "'${db_pass}'"

# =============================================================================
# LOCAL BACKUP CONFIGURATIONS
# =============================================================================
gitlab_rails["manage_backup_path"] = true
gitlab_rails["backup_path"] = "/var/opt/gitlab/backups"
gitlab_rails["backup_multipart_chunk_size"] = 104857600
gitlab_rails["backup_encryption"] = "AES256"
gitlab_rails["backup_keep_time"] = 604800

# =============================================================================
# OBJECT STORAGE (S3) CONFIGURATIONS - BY TYPE
# =============================================================================

# Artifacts (CI/CD files)
gitlab_rails["artifacts_enabled"] = true
gitlab_rails["artifacts_object_store_enabled"] = true
gitlab_rails["artifacts_object_store_remote_directory"] = "'${artifact_bucket}'"
gitlab_rails["artifacts_object_store_connection"] = {"provider": "AWS", "region": "'${aws_region}'", "use_iam_profile" => true}

# LFS (Large File Storage)
gitlab_rails["lfs_enabled"] = true
gitlab_rails["lfs_object_store_enabled"] = true
gitlab_rails["lfs_object_store_remote_directory"] = "'${lfs_bucket}'"
gitlab_rails["lfs_object_store_connection"] = {"provider": "AWS", "region": "'${aws_region}'", "use_iam_profile" => true}

# Uploads (file uploads)
gitlab_rails["uploads_enabled"] = true
gitlab_rails["uploads_object_store_enabled"] = true
gitlab_rails["uploads_object_store_remote_directory"] = "'${uploads_bucket}'"
gitlab_rails["uploads_object_store_connection"] = {"provider": "AWS", "region": "'${aws_region}'", "use_iam_profile" => true}

# Packages (pacotes npm, maven, etc.)
gitlab_rails["packages_enabled"] = true
gitlab_rails["packages_object_store_enabled"] = true
gitlab_rails["packages_object_store_remote_directory"] = "'${packages_bucket}'"
gitlab_rails["packages_object_store_connection"] = {"provider": "AWS", "region": "'${aws_region}'", "use_iam_profile" => true}

# Backup S3
gitlab_rails["backup_upload_remote_directory"] = "'${backup_bucket}'"
gitlab_rails["backup_upload_connection"] = {"provider" => "AWS", "region": "'${aws_region}'", "use_iam_profile" => true}
gitlab_rails["backup_upload_storage_class"] = "STANDARD"

# =============================================================================
# GLOBAL OBJECT STORAGE (S3) CONFIGURATION
# =============================================================================
gitlab_rails["object_store_enabled"] = true
gitlab_rails["object_store"]["connection"] = {
  "provider" => "AWS",
  "region" => "'${aws_region}'",
  "aws_access_key_id" => "'${s3_access_key}'",
  "aws_secret_access_key" => "'${s3_secret_key}'"
}

# =============================================================================
# STORAGE AND ENCRYPTION CONFIGURATIONS
# =============================================================================
gitlab_rails["object_store"]["storage_options"] = {
  "server_side_encryption" => true
}

# =============================================================================
# BACKGROUND UPLOAD CONFIGURATIONS (PERFORMANCE)
# =============================================================================
gitlab_rails["lfs_object_store_background_upload"] = true
gitlab_rails["uploads_object_store_background_upload"] = true
gitlab_rails["packages_object_store_background_upload"] = true
gitlab_rails["artifacts_object_store_background_upload"] = true

# =============================================================================
# PROJECTS AND FEATURES CONFIGURATIONS
# =============================================================================
gitlab_rails["gitlab_default_can_create_group"] = true
gitlab_rails["gitlab_default_projects_features_builds"] = true
gitlab_rails["gitlab_default_projects_features_issues"] = true
gitlab_rails["gitlab_default_projects_features_merge_requests"] = true
gitlab_rails["gitlab_default_projects_features_snippets"] = true
gitlab_rails["gitlab_default_projects_features_wiki"] = true

# =============================================================================
# PERFORMANCE AND CONNECTION CONFIGURATIONS
# =============================================================================
gitlab_rails["object_store_upload_connection_pool_size"] = 10
gitlab_rails["object_store_download_connection_pool_size"] = 10
gitlab_rails["object_store_connection_pool_timeout"] = 5
gitlab_rails["object_store_connection_pool_keepalive"] = 30

# =============================================================================
# CACHE AND LOGS CONFIGURATIONS
# =============================================================================
gitlab_rails["log_level"] = "INFO"
gitlab_rails["object_store_cache_enabled"] = true
gitlab_rails["object_store_cache_expires_in"] = 3600

# Integrations and SAML
gitlab_rails["omniauth_allow_single_sign_on"] = ["saml"]
gitlab_rails["omniauth_block_auto_created_users"] = false
gitlab_rails["omniauth_auto_link_saml_user"] = true
gitlab_rails["omniauth_providers"] = [
  {
    name: "bitbucket",
    app_id: "${bitbucket_app_key}",
    app_secret: "${bitbucket_app_secret}",
    url: "https://bitbucket.org/"
  },
  {
    name: "saml", # keep lowercase
    label: "SSO Login", # optional label for login button, defaults to "Saml"
    args: {
      assertion_consumer_service_url: "https://${dns_record}/users/auth/saml/callback",
      idp_cert_fingerprint: "${idp_cert}",
      idp_sso_target_url: "${idp_url}",
      issuer: "https://${dns_record}",
      name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
    }
  }
]
EOF'

# Download gitlab-secrets.json from S3
# Important: The EC2 instance must have an Instance Role with s3:GetObject permission for this file (critical for GitLab operation)
sudo aws s3 cp s3://s3-gitlab-files/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json

sudo gitlab-ctl reconfigure

# Stop GitLab before fixing permissions/locks
sudo gitlab-ctl stop

# Run migrations that usually hang according to GitLab docs
sudo gitlab-rake db:seed_fu FILTER=004_create_base_work_item_types

# Permissions on gitlab-secrets.json and gitlab.rb
sudo chmod 600 /etc/gitlab/gitlab-secrets.json
sudo chown root:root /etc/gitlab/gitlab-secrets.json
sudo chmod 600 /etc/gitlab/gitlab.rb
sudo chown root:root /etc/gitlab/gitlab.rb

# PostgreSQL
sudo chown -R gitlab-psql:gitlab-psql /var/opt/gitlab/postgresql
sudo chmod -R 700 /var/opt/gitlab/postgresql
sudo rm -f /var/opt/gitlab/postgresql/data/postmaster.pid

# Redis
sudo chown -R git:git /var/opt/gitlab/redis
sudo chmod -R 700 /var/opt/gitlab/redis
sudo rm -f /var/opt/gitlab/redis/*.pid /var/opt/gitlab/redis/redis.socket /var/opt/gitlab/redis/dump.rdb

# Prometheus
sudo chown -R git:git /var/opt/gitlab/prometheus
sudo chmod -R 700 /var/opt/gitlab/prometheus
sudo rm -f /var/opt/gitlab/prometheus/prometheus.pid /var/opt/gitlab/prometheus/data/lock

# Alertmanager
sudo chown -R git:git /var/opt/gitlab/alertmanager
sudo chmod -R 700 /var/opt/gitlab/alertmanager
sudo rm -f /var/opt/gitlab/alertmanager/alertmanager.pid

# Gitaly
sudo chown -R git:git /var/opt/gitlab/gitaly
sudo chmod -R 700 /var/opt/gitlab/gitaly

# GitLab Rails
sudo chown -R git:git /var/opt/gitlab/gitlab-rails
sudo chmod -R 700 /var/opt/gitlab/gitlab-rails

# Enforcing permissions
sudo chown git:git /var/log/gitlab/puma/puma_stdout.log 
sudo chmod 640 /var/log/gitlab/puma/puma_stdout.log 

sudo chown -R git:git  /opt/gitlab/embedded/service/gitlab-rails/log/application_json.log
sudo chmod -R 700 /opt/gitlab/embedded/service/gitlab-rails/log/application_json.log
sudo chmod -R 700 /opt/gitlab/embedded/service/gitlab-rails/log/
sudo chmod -R 700 /opt/gitlab/embedded/service/gitlab-rails/log/
sudo chmod -R 700 /opt/gitlab/embedded/service/gitlab-rails/log/graphql_json.log
sudo chmod -R 700 /opt/gitlab/embedded/service/gitlab-rails/log/graphql_json.log
sudo chmod -R 700 /opt/gitlab/embedded/service/gitlab-rails/log/graphql_json.log

sudo chown -R git:git /opt/gitlab/embedded/service/gitlab-rails/log
sudo chmod 750 /opt/gitlab/embedded/service/gitlab-rails/log

# Global adjustment
sudo chmod -R 700 /var/opt/gitlab

# Redis adjustment in the kernel
echo 'vm.overcommit_memory = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Add the task to the root crontab if it doesn't already exist
(crontab -l 2>/dev/null; echo "0 6 * * * /opt/gitlab/bin/gitlab-backup create CRON=1") | crontab -

# Start GitLab after configuration
sudo gitlab-ctl reconfigure

sleep 10

sudo gitlab-ctl restart

# Disable GraphQL bug
sudo gitlab-rails runner "Feature.disable(:graphql_pipeline_details)"

# Check if Object Storage is configured
echo "Checking Object Storage configuration..."
sudo gitlab-rake gitlab:check SANITIZE=true

# Check GitLab status
sudo gitlab-ctl status

# Install CloudWatch agent (Ubuntu)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Resize the disk if the EBS size has been increased
lsblk
sudo resize2fs /dev/nvme1n1

# Fallback to reconfigure in case of errors in migrations or permissions
sudo gitlab-ctl reconfigure