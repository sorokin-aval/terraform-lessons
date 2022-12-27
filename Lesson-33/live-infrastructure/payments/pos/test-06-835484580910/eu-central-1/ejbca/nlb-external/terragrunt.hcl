include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/ejbca/nlb-external.hcl")
}

locals {
  app_vars = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}