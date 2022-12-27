include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/core-infrastructure/vpc-info.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}
