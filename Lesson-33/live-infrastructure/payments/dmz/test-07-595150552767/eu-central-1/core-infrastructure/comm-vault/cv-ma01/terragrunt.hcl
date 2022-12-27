include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/cv-ma01.hcl")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${substr(local.account_vars.locals.aws_account_id, -5, -1)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  name        = local.name
  domain      = "${local.account_vars.locals.core_subdomain}.${local.account_vars.locals.domain}"
  hosted_zone = "${local.account_vars.locals.core_subdomain}.${local.account_vars.locals.domain}"
}
