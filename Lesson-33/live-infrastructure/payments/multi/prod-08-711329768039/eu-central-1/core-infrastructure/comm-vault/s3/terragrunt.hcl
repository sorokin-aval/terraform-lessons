include "root" {
  path   = find_in_parent_folders()
  expose = true
}


include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/cv-s3.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {}

