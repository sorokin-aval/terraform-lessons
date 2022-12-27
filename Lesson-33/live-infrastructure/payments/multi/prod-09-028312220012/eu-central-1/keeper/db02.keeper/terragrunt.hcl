include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/keeper/db.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet          = "LZ-RBUA_Payments_*-RestrictedC"
  zone            = "eu-central-1c"
}
