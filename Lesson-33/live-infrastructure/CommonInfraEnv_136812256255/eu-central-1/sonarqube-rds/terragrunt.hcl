include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//rds?ref=rds_v0.0.1"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out exact variables for reuse
  env      = local.account_vars.locals.environment
  tags_map = local.common_tags.locals

  db_name  = "sonarqube"
  rds_name = "${local.db_name}"
}

inputs = {
  identifier = local.rds_name

  engine               = "postgres"
  engine_version       = "13.3"
  family               = "postgres13"  # DB parameter group
  major_engine_version = "postgres-13" # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 300
  storage_encrypted     = false

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  name                   = upper(local.db_name)
  username               = "sonarqube"
  create_random_password = true
  random_password_length = 16
  port                   = 5432

  multi_az      = false
  subnets_names = ["LZ-AVAL_COMMON_TEST-InternalA", "LZ-AVAL_COMMON_TEST-InternalB"]

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = "${local.db_name}-rds-monitoring-role"

  tags = local.tags_map
}

