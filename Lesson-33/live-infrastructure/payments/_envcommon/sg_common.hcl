dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  name            = local.app_vars.locals.name
  use_name_prefix = false
  description     = "Common security group for ${local.app_vars.locals.name}"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.app_vars.locals.tags
}
