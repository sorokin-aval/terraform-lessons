terraform {
  source = local.account_vars.sources_vpc_info
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  lb_subnets_names_filter  = local.account_vars.tier1_subnet_filter
  app_subnets_names_filter = local.account_vars.tier2_subnet_filter
}
