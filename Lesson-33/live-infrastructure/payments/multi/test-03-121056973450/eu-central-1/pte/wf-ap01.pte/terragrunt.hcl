include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/pte/wf_ap.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet = "LZ-RBUA_Payments_*-InternalA"
  zone   = "eu-central-1a"
}
