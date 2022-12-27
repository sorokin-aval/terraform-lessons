include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/is-card/cnp-vienna-ap.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

skip = try(local.account_vars.locals.ec2_types[local.name], "") == "" ? true : false

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  subnet = "LZ-RBUA_Payments_*-InternalC"
  zone   = "eu-central-1c"
}