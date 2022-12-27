dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["route53-endpoint"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name           = replace(local.account_vars.locals.domain, ".", "-")
  vpc            = local.account_vars.locals.vpc
  security_group = local.account_vars.locals.sg["dns"]
  tags           = local.account_vars.locals.tags
  subnets        = dependency.vpc.outputs.app_subnets.ids
}
