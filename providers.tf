provider "aws" {
  region  = var.account_region
  profile = "devops"
  default_tags {
    tags = {
      "Project" = "Gitlab-Self-Hosted"
      "Owner"   = "my person"
      "Team"    = "DevOps"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.30.0"
    }
  }

  #Configure your backend s3 with dynamodb for state locking
  # backend "s3" {
  #   bucket  = "terraform-bucket-states"
  #   key     = "gitlab-self-hosted/terraform/state"
  #   region  = "us-east-1"
  #   profile = "your-profile"
  # }
}