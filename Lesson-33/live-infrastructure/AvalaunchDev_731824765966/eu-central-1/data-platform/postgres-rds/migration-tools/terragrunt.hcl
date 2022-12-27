include {
  path = "${find_in_parent_folders()}"
}

terraform {
     source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "eu-central-1"
    }

    provider "vault" {
    address         = "http://vault.apps.dev.data.rbua:80"
    token           = "s.EKd3fPIO0FIO2S3UcsE2JFUT"
    skip_tls_verify = true
    max_retries     = 2
    } 
  EOF
}

dependency "sg" {
  config_path = "sg"
  mock_outputs = {
  security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan","init"]
}

# Hardcode!
dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
  db_name      = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-${basename(get_terragrunt_dir())}"
}

inputs = {
  identifier = "${ replace(local.db_name,"_","-") }"

  engine               = "postgres"
  engine_version       = "14.2"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"            # DB option group
  instance_class       = "db.t4g.medium"

  allocated_storage     = 40
  max_allocated_storage = 500
  storage_encrypted     = true

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  username               = "postgres"
  create_random_password = true
  random_password_length = 32
  port                   = 5432

  multi_az               = false
  db_subnet_group_name   = "rbua-postgresql"
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]

  create_cloudwatch_log_group     = true
  maintenance_window              = "Mon:01:00-Mon:01:30"
  backup_window                   = "00:00-01:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = "${local.tags_map.Project}-monitoring-role"

  tags = local.tags_map

  environment                 =  "uat"
  service_name                =  "migration-tools"
  database_name               =  local.db_name
  vault_nosuperuser           =  "${local.tags_map.Project}-user"
  iam_user                    =  ["nifi-iam-user-1","nifi-iam-user-2"]
}
