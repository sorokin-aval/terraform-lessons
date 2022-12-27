skip = try(local.account_vars.locals.rds_types[local.name], "") == "" ? true : false

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("rds-sg")
}

terraform {
  source = local.account_vars.locals.sources["rds"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${local.app_vars.locals.name}"
}

inputs = {
  identifier = local.name

  engine                 = "mysql"
  engine_version         = "5.7.40"
  instance_class         = try(local.account_vars.locals.rds_types[local.name], "")
  multi_az               = try(local.account_vars.locals.rds_multi_az[local.name], true)
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  domain                 = ""

  allocated_storage     = 10
  max_allocated_storage = 110

  storage_encrypted = true

  username = local.app_vars.locals.name
  port     = 3306

  maintenance_window              = "Tue:21:18-Tue:21:48"
  backup_window                   = "00:16-00:46"
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  create_cloudwatch_log_group     = true
  auto_minor_version_upgrade      = false

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  # monitoring_role_arn = ""
  monitoring_interval         = 60
  monitoring_role_name        = "${local.name}-monitoring"
  monitoring_role_description = "${local.name} monitoring role"

  # DB subnet group
  create_db_subnet_group          = true
  subnet_ids                      = dependency.vpc.outputs.db_subnets.ids
  db_subnet_group_name            = local.name
  db_subnet_group_use_name_prefix = false

  # DB option group
  major_engine_version   = "5.7"
  create_db_option_group = false
  # option_group_name            = "${local.name}-option"
  # option_group_use_name_prefix = false
  # options = []

  # DB parameter group
  family                          = "mysql5.7"
  create_db_parameter_group       = true
  parameter_group_name            = "${local.name}-parameter"
  parameter_group_use_name_prefix = false
  parameters                      = []

  tags = merge(local.app_vars.locals.tags, { map-db = "" })
}
