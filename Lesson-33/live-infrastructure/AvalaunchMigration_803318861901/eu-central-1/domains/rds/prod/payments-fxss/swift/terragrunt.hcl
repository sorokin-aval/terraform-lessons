include {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = find_in_parent_folders("common.hcl")
}

inputs = {
  storage_type          = "gp2"
  allocated_storage     = 500
  max_allocated_storage = 1000
}