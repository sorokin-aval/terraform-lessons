include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/acm.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  certificates = {
    "${local.app_vars.locals.name}" = {
      domain_name = "slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
    }
  }
}
