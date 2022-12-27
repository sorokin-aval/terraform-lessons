terraform {
  source = local.account_vars.locals.sources["vpc-info"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {}