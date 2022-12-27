dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/rds-${local.name}")
}

dependency "subnet_group" {
  config_path = find_in_parent_folders("rds/subnet-group")
}

iam_role = local.account_vars.iam_role

locals {
  name         = "${basename(get_terragrunt_dir())}"
  identifier   = "${local.tags_map.env}-${lower(local.tags_map.System)}-${local.name}"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags = merge(
    local.tags_map,
    try(local.account_vars.tag_schedule, "") != "" ? { Schedule = local.account_vars.tag_schedule } : {}
  )
}

terraform {
  source = local.account_vars.sources_rds
}

inputs = {
  identifier             = local.identifier
  instance_class         = local.account_vars["rds_${local.name}_instance_class"]
  allocated_storage      = local.account_vars["rds_${local.name}_allocated_storage"]
  multi_az               = local.account_vars["rds_${local.name}_multi_az"]
  db_subnet_group_name   = dependency.subnet_group.outputs.db_subnet_group_id
  vpc_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
  snapshot_identifier    = local.account_vars["rds_${local.name}_snapshot_identifier"]
  engine_version         = local.account_vars["rds_${local.name}_engine_version"]
  major_engine_version   = local.account_vars["rds_${local.name}_major_engine_version"] # DB option group
  engine_version         = local.account_vars["rds_${local.name}_engine_version"]
  major_engine_version   = local.account_vars["rds_${local.name}_major_engine_version"] # DB option group
  family                 = local.account_vars["rds_${local.name}_major_engine_version"] # DB parameter group

  engine                    = "postgres"
  create_db_option_group    = false
  create_db_parameter_group = false
  storage_encrypted         = false
  domain                    = ""           # Override account level 'domain' variable

  tags = local.tags
}
