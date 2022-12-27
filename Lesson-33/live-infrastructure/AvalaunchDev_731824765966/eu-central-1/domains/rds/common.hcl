iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-avalaunch-rds.git//?ref=v1.1.0"
}

dependency "rds_role" {
  config_path = find_in_parent_folders("services/rds-active-directory/ua-avalaunch-rds-ad-role")
}

locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  db_name     = basename(get_terragrunt_dir())
  domain_name = basename(dirname(get_terragrunt_dir()))
  env         = local.env_vars.locals.tech_env

  vault_path    = "secret/service-internal-secrets/${local.env}/${local.domain_name}/common/${local.db_name}-${local.env}/rds"
  vault_address = "https://vault.dev.avalaunch.aval/"

  tags_map = local.common_tags.locals.common_tags
}

inputs = {
  identifier = "${local.db_name}-${local.env}"

  engine              = "postgres"
  engine_version      = "12.11"
  instance_class      = "db.t4g.medium"
  multi_az            = false
  deletion_protection = true

  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name                = "application"
  username               = "postgres"
  create_random_password = true
  port                   = "5432"

  domain               = "d-9967190de0"
  domain_iam_role_name = dependency.rds_role.outputs.iam_role_name

  create_db_subnet_group = true

  sg_ingress_cidr_blocks = "CGNATSubnet"

  maintenance_window      = "Sat:02:00-Sat:04:00"
  backup_window           = "01:15-01:45" # UTC
  backup_retention_period = 7

  parameter_group_name   = "${local.db_name}-${local.env}"
  create_db_option_group = false
  family                 = "postgres12"

  vault_path    = local.vault_path
  vault_address = local.vault_address

  tags = local.tags_map
}
