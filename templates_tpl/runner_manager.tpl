#!/bin/bash

set -x

# Install GitLab Runner
#Alternativa erro de pacote manual
curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner-helper-images.deb"
curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_arm64.deb"
sudo dpkg -i gitlab-runner-helper-images.deb gitlab-runner_arm64.deb
sudo apt-get install -y gitlab-runner

#Install Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo bash -c 'cat <<EOF > /etc/gitlab-runner/config.toml
concurrent = 25
log_level ="info"
log_format ="runner"
check_interval= 1
shutdown_timeout= 15

[[runners]]
  name = "${runner_name_amd64}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_amd64}"
  limit = 0
  run_untagged = false
  locked = true
  tags = ["amd64"]

  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_amd64}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_amd64}
      idle_time = "${idleTime}"
      preemptive_mode = false
    
    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_amd64_medium}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_amd64_medium}"
  limit = 0
  run_untagged = false
  locked = true
  tags = ["amd64-medium"]

  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_amd64_medium}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_amd64}
      idle_time = "${idleTime}"
      preemptive_mode = false
    
    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_amd64_large}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_amd64_large}"
  limit = 0
  run_untagged = false
  locked = true
  tags = ["amd64-large"]

  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_amd64_large}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_amd64}
      idle_time = "${idleTime}"
      preemptive_mode = false
    
    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_arm64}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_arm64}"
  limit = 0
  run_untagged = true
  locked = true
  
  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_arm64}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_arm64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_arm64_medium}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_arm64_medium}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["arm64-medium"]

  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_arm64_medium}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_arm64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_arm64_large}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_arm64_large}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["arm64-large"]
  
  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_arm64_large}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_arm64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_arm64_dedicated}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_arm64_dedicated}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["arm64-dedicated"]
  
  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_arm64_dedicated}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_arm64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_arm64_medium_dedicated}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_arm64_medium_dedicated}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["arm64-medium-dedicated"]

  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_arm64_medium_dedicated}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_arm64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_arm64_large_dedicated}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_arm64_large_dedicated}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["arm64-large-dedicated"]
  
  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_arm64_large_dedicated}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_arm64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_amd64_dedicated}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_amd64_dedicated}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["amd64-dedicated"]
  
  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_amd64_dedicated}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_amd64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_amd64_medium_dedicated}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_amd64_medium_dedicated}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["amd64-medium-dedicated"]

  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_amd64_medium_dedicated}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_amd64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]

[[runners]]
  name = "${runner_name_amd64_large_dedicated}"
  url = "https://${dns_record}"
  clone_url = "https://${dns_record}"
  executor = "docker-autoscaler"
  request_concurrency = 4
  token = "${runner_token_amd64_large_dedicated}"
  limit = 0
  run_untagged = true
  locked = true
  tags = ["amd64-large-dedicated"]
  
  [runners.autoscaler]
    plugin = "aws"
    executor = "docker"
    capacity_per_instance = 3
    max_use_count = ${maxBuilds}
    max_instances = 20
    trace = true

    [runners.autoscaler.plugin_config]
      name = "${asg_name_amd64_large_dedicated}"

    [runners.autoscaler.connector_config]
      username          = "ubuntu"
      use_external_addr = false
      
    [[runners.autoscaler.policy]]
      idle_count = ${idleCount_amd64}
      idle_time = "${idleTime}"
      preemptive_mode = false

    [runners.docker]
      pull_policy = ["if-not-present"]
      image = "ubuntu:latest"
      privileged = true
      volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]
EOF'

sudo gitlab-runner fleeting install

sudo systemctl enable --now gitlab-runner