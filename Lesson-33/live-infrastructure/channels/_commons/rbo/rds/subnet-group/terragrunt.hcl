dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

locals {
  name         = "account-db-subnets"
  description  = "Subnets for DBs in this account"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = local.account_vars.sources_rds_subnet_group
}

iam_role = local.account_vars.iam_role

inputs = {
  name            = local.name
  description     = local.description
  use_name_prefix = false
  subnet_ids      = dependency.vpc.outputs.db_subnets.ids
  tags            = local.tags_map
}
