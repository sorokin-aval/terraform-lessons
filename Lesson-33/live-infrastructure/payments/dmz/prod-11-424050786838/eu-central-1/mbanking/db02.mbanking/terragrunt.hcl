include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/${basename(dirname(get_terragrunt_dir()))}/db.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet = "RBUA_Payments_*-RestrictedC"
  zone   = "eu-central-1c"
}