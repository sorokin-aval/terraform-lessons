include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/vpc-info.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}
