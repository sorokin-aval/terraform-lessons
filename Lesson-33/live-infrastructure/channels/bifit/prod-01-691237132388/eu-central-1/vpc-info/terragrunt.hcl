include {
  path = find_in_parent_folders()
}

terraform {
  source = local.account_vars.sources_vpc_info
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  tr_subnets_names_filter  = local.account_vars.tier1_subnet_filter
  in_subnets_names_filter = local.account_vars.tier2_subnet_filter
  rt_subnets_names_filter = local.account_vars.tier3_subnet_filter
}
