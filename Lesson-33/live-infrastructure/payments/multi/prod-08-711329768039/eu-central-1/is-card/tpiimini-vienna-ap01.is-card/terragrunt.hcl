include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/is-card/tpiimini-vienna-ap.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet = "LZ-RBUA_Payments_*-InternalB"
  zone   = "eu-central-1b"
}