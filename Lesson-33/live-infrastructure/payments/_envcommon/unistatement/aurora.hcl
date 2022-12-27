dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["aurora"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${local.app_vars.locals.name}"
}

inputs = {
  name           = local.name
  engine         = "aurora-postgresql"
  engine_version = "12.11"

  instances = {
    "01" = {
      instance_class = "db.t3.large"
    }
    "02" = {
      instance_class = "db.t3.large"
      promotion_tier = 5
    }
  }

  vpc_id                 = dependency.vpc.outputs.vpc_id.id
  create_db_subnet_group = true
  db_subnet_group_name   = local.name
  subnets                = dependency.vpc.outputs.db_subnets.ids

  create_security_group          = true
  security_group_use_name_prefix = false
  allowed_cidr_blocks            = concat(
    local.account_vars.locals.ips["avalaunch-k8s-nat"],
    local.account_vars.locals.pools["ho-pool-devpay"],
    ["10.0.0.0/8"]
  )
  security_group_egress_rules = {}

  master_username              = "postgres"
  create_random_password       = true
  preferred_backup_window      = "00:00-02:00"
  preferred_maintenance_window = "mon:02:00-mon:04:00"

  apply_immediately   = true
  skip_final_snapshot = true

  create_db_cluster_parameter_group          = true
  db_cluster_parameter_group_name            = "${local.name}-parameter"
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_family          = "aurora-postgresql12"
  db_cluster_parameter_group_description     = "Cluster parameter group for ${local.name}"
  db_cluster_parameter_group_parameters      = [
    { name : "authentication_timeout", value : 300, apply_method : "immediate" },
    { name : "log_connections", value : 1, apply_method : "immediate" },
    { name : "log_disconnections", value : 1, apply_method : "immediate" },
    { name : "log_min_duration_statement", value : "-1", apply_method : "immediate" },
    { name : "log_min_messages", value : "warning", apply_method : "immediate" },
    { name : "log_min_messages", value : "warning", apply_method : "immediate" },
    { name : "log_rotation_size", value : 1000000, apply_method : "immediate" },
    { name : "log_statement", value : "ddl", apply_method : "immediate" },
    { name : "max_connections", value : 400, apply_method : "pending-reboot" },
    { name : "max_prepared_transactions", value : 100, apply_method : "pending-reboot" },
    { name : "max_stack_depth", value : 7680, apply_method : "immediate" },
    { name : "password_encryption", value : "scram-sha-256", apply_method : "immediate" },
    { name : "track_commit_timestamp", value : 0, apply_method : "pending-reboot" },
    { name : "work_mem", value : 16000, apply_method : "immediate" },
  ]

  create_db_parameter_group          = true
  db_parameter_group_name            = "${local.name}-parameter"
  db_parameter_group_use_name_prefix = false
  db_parameter_group_family          = "aurora-postgresql12"
  db_parameter_group_description     = "DB parameter group for ${local.name}"
  db_parameter_group_parameters      = []

  enabled_cloudwatch_logs_exports = ["postgresql"]

  deletion_protection = true

  tags = merge(local.app_vars.locals.tags, { map-db = "d-server-00wlwosfsl5z6u" })
}
