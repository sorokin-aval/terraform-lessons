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
  # snapshot_identifier = "rds-trust"

  engine                 = "oracle-se2"
  engine_version         = "19.0.0.0.ru-2022-04.rur-2022-04.r1"
  instance_class         = try(local.account_vars.locals.rds_types[local.name], "")
  multi_az               = try(local.account_vars.locals.rds_multi_az[local.name], true)
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  license_model          = "bring-your-own-license"
  ca_cert_identifier     = "rds-ca-2019"

  allocated_storage     = 50
  max_allocated_storage = 110

  storage_encrypted = true

  db_name  = "TRUST"
  username = "admin"
  port     = 1521

  domain = ""
  # domain_iam_role_name = dependency.iam-role.outputs.iam_role_name

  maintenance_window              = "Mon:00:00-Mon:01:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["alert", "audit"]
  create_cloudwatch_log_group     = true
  auto_minor_version_upgrade      = true

  backup_retention_period = 3
  skip_final_snapshot     = true
  deletion_protection     = true
  copy_tags_to_snapshot   = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  # monitoring_role_arn = ""
  monitoring_interval                   = 60
  monitoring_role_name                  = "${local.name}-monitoring"
  monitoring_role_description           = "${local.name} monitoring role"

  # DB subnet group
  create_db_subnet_group          = true
  subnet_ids                      = dependency.vpc.outputs.db_subnets.ids
  db_subnet_group_name            = local.name
  db_subnet_group_use_name_prefix = false

  # DB option group
  major_engine_version         = "19"
  create_db_option_group       = true
  option_group_name            = "${local.name}-option"
  option_group_use_name_prefix = false
  option_group_description     = "Option group for ${local.name}"
  options                      = [
    {
      option_name                    = "SSL"
      port                           = 1575
      vpc_security_group_memberships = [dependency.sg.outputs.security_group_id]

      option_settings = [
        {
          name  = "FIPS.SSLFIPS_140"
          value = "FALSE"
        },
        {
          name  = "SQLNET.SSL_VERSION"
          value = "1.2 or 1.0"
        }
      ]
    },
    {
      option_name = "Timezone"

      option_settings = [
        {
          name  = "TIME_ZONE"
          value = "Europe/Athens"
        }
      ]
    },
    {
      option_name = "STATSPACK"
    }
  ]

  # DB parameter group
  family                          = "oracle-se2-19"
  create_db_parameter_group       = true
  parameter_group_name            = "${local.name}-parameter"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "Parameter group for ${local.name}"
  parameters                      = [
    {
      name  = "sqlnetora.sqlnet.allowed_logon_version_client"
      value = "8"
    },
    {
      name  = "sqlnetora.sqlnet.allowed_logon_version_server"
      value = "8"
    },
  ]

  character_set_name = "CL8MSWIN1251"

  tags = merge(local.app_vars.locals.tags, { map-db = "d-server-00ei2x3nt1e5v5" })
}
