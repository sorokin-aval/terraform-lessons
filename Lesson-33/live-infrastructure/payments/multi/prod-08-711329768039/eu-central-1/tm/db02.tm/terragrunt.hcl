include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/tm/db.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet          = "LZ-RBUA_Payments_*-RestrictedB"
  zone            = "eu-central-1b"
  security_groups = ["ad", "ssh", "observable", "${dependency.sg.outputs.security_group_name}", "general-tm-1", "general-tm-2"]
  ebs_optimized   = false
}
