skip = try(local.account_vars.locals.rds_types[local.name], "") == "" ? true : false

dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "iam-role" {
  config_path = find_in_parent_folders("core-infrastructure/iam-role-rds-domain")
}

dependencies {
  paths = [
    find_in_parent_folders("sg"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["rds"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  identifier = replace(local.name, ".", "-")

  engine               = "postgres"
  engine_version       = "12.7"
  family               = "postgres12"
  major_engine_version = "12"
  instance_class       = try(local.account_vars.locals.rds_types[local.name], "")

  allocated_storage     = 300
  max_allocated_storage = 600

  db_name  = local.app_vars.locals.name
  username = local.app_vars.locals.name
  port     = 5432

  domain               = local.account_vars.locals.directory_service
  domain_iam_role_name = dependency.iam-role.outputs.iam_role_name

  multi_az               = try(local.account_vars.locals.rds_multi_az[local.name], true)
  db_subnet_group_name   = "restricted-db-subnet"
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:00:30"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true
  auto_minor_version_upgrade      = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${local.name}-monitoring-role"
  monitoring_role_description           = "${local.name} monitoring role"

  parameters = [
    { name = "client_encoding", value = "utf8" },
    { name = "rds.custom_dns_resolution", value = 0, apply_method = "pending-reboot" }
  ]

  tags = merge(local.app_vars.locals.tags, { map-db = "d-server-00wlwosfsl5z6u" })

}
