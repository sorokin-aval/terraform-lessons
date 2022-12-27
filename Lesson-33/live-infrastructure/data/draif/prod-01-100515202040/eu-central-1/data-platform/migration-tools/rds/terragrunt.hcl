include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "sg" {
  config_path  = "../sg"
  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

dependency "subnet_group" {
  config_path = "../../../core-infrastructure/rds-subnet-group"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  db_name      = "${local.common_tags.locals.Name}_${local.common_tags.locals.Environment}"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds-aurora.git?ref=v7.1.0"
}

inputs = {
  name           = "migrationtools"
  engine         = "aurora-postgresql"
  engine_version = "13.6"
  instance_class = "db.t3.large"
  instances      = {
    master  = {}
    replica = {
      instance_class = "db.t3.large"
    }
  }
  allocated_storage                     = 20
  max_allocated_storage                 = 500
  storage_encrypted                     = true
  apply_immediately                     = true
  db_name                               = "MigrationTools"
  master_username                       = "postgres"
  iam_database_authentication_enabled   = true
  port                                  = 5432
  multi_az                              = false
  db_subnet_group_name                  = dependency.subnet_group.outputs.db_subnet_group_id
  vpc_security_group_ids                = [dependency.sg.outputs.security_group_id]
  allowed_security_groups               = [dependency.sg.outputs.security_group_id]
  security_group_id                     = [dependency.sg.outputs.security_group_id]
  create_db_subnet_group                = false
  create_security_group                 = false
  backup_retention_period               = 7
  skip_final_snapshot                   = true
  deletion_protection                   = true
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = "${local.db_name}-rds-monitoring-role"
  tags                                  = local.tags_map
  maintenance_window                    = "Sun:01:00-Sun:02:00"
  backup_window                         = "03:00-06:00"
}
