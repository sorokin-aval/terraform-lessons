include "root" {
  path   = find_in_parent_folders()
  expose = true
}


include "envcommon" {
  path = find_in_parent_folders("_envcommon/elb/alb-internal-sg01.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}
