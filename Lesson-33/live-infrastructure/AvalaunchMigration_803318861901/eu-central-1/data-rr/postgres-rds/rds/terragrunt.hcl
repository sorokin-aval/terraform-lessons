include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-postgresql-rds//?ref=v1.0.3"
}

dependency "sg" {
  config_path  = "../sg"
  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "fmt", "show"]
}


locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  db_name      = "${local.project_vars.locals.project_prefix}-01"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "vault" {
      address = "https://vault.prod.avalaunch.aval"
      auth_login {
        path = "auth/kubernetes-common/login"

        parameters = {
          role = "atlantis"
          jwt  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
        }
      }
    }
  EOF
}

inputs = {
  identifier = "${replace(local.db_name, "_", "-")}"

  engine                     = "postgres"
  engine_version             = "14"
  auto_minor_version_upgrade = true
  family                     = "postgres14" # DB parameter group
  major_engine_version       = "14"         # DB option group
  instance_class             = "db.t4g.small"

  allocated_storage     = 40
  max_allocated_storage = 500
  storage_encrypted     = true

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  username               = "postgres"
  create_random_password = true
  random_password_length = 32
  port                   = 5432

  multi_az               = true
  db_subnet_group_name   = "eks-20221109091901186500000002"
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]

  create_cloudwatch_log_group     = true
  maintenance_window              = "Mon:01:00-Mon:01:30"
  backup_window                   = "00:00-01:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = false
  monitoring_role_name                  = "${local.tags_map.Project}-monitoring-role"

  tags = local.tags_map

  environment       = lower(local.tags_map["security:environment"])
  service_name      = local.tags_map["business:team"]
  database_name     = local.db_name
  vault_nosuperuser = "${local.tags_map["business:team"]}-user"
  vault_path        = "secret/service-internal-secrets"

  copy_tags_to_snapshot               = true
  kms_key_id                          = local.project_vars.locals.kms_key
  deletion_protection                 = true
  iam_database_authentication_enabled = true
}
