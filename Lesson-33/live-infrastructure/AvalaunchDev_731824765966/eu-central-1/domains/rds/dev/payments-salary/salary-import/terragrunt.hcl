include {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = find_in_parent_folders("common.hcl")
}
