include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/stp/was-ap.hcl")
}

locals {
  app_vars = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet = "LZ-RBUA_Payments_*-InternalC"
  zone   = "eu-central-1c"
  tags   = merge(local.app_vars.locals.tags, { map-migrated = "d-server-005jcjnm1ma3kl" })
}