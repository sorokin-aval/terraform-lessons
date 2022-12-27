include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/avtokassa/route53-nlb.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}
