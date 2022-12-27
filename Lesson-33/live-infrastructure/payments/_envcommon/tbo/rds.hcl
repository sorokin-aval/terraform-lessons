skip = try(local.account_vars.locals.rds_types[local.name], "") == "" ? true : false

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("rds-sg")
}

dependency "iam-role" {
  config_path = find_in_parent_folders("core-infrastructure/iam-role-rds-domain")
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

  engine                 = "sqlserver-se"
  engine_version         = "13.00.6419.1.v1"
  instance_class         = try(local.account_vars.locals.rds_types[local.name], "")
  multi_az               = try(local.account_vars.locals.rds_multi_az[local.name], true)
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  license_model          = "license-included"
  timezone               = "FLE Standard Time"
  character_set_name     = "Latin1_General_CI_AS"

  allocated_storage     = 20
  max_allocated_storage = 40

  storage_encrypted = true

  username = "admin"
  port     = 1433

  domain               = local.account_vars.locals.directory_service
  domain_iam_role_name = dependency.iam-role.outputs.iam_role_name

  maintenance_window              = "Mon:00:00-Mon:01:00"
  backup_window                   = "02:00-04:00"
  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true
  auto_minor_version_upgrade      = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  # monitoring_role_arn = ""
  monitoring_interval                   = 30
  monitoring_role_name                  = "${local.name}-monitoring"
  monitoring_role_description           = "${local.name} monitoring role"

  # DB subnet group
  create_db_subnet_group          = true
  subnet_ids                      = dependency.vpc.outputs.db_subnets.ids
  db_subnet_group_name            = local.name
  db_subnet_group_use_name_prefix = false

  # DB option group
  major_engine_version         = "13.00"
  create_db_option_group       = true
  option_group_name            = "${local.name}-option"
  option_group_use_name_prefix = false
  option_group_description     = "Option group for ${local.name}"
  options                      = [
    {
      option_name     = "SQLSERVER_BACKUP_RESTORE"
      option_settings = [
        {
          name  = "IAM_ROLE_ARN"
          value = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/service-role/dbre-bucket"
        }
      ]
    }
  ]

  # DB parameter group
  family                          = "sqlserver-se-13.0"
  create_db_parameter_group       = true
  parameter_group_name            = "${local.name}-parameter"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "Parameter group for ${local.name}"
  # parameters = []

  apply_immediately = true

  tags = merge(local.app_vars.locals.tags, { map-dba = "d-server-02gx2y7f9cjc7s" })
}
