include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/acm.hcl"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}
