include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/pte/vpos_db.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet        = "LZ-RBUA_Payments_*-RestrictedA"
  zone          = "eu-central-1a"
  ebs_optimized = true
}
