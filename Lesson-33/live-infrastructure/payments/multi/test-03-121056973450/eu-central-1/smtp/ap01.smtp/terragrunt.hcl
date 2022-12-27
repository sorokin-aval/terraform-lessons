include "root" {
  path   = find_in_parent_folders()
  expose = true
}


include "envcommon" {
  path = find_in_parent_folders("_envcommon/smtp/ap.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  domain = local.account_vars.locals.new_domain
}
