include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/${basename(dirname(get_terragrunt_dir()))}/ap.hcl")
}

locals {
  app_vars = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet          = "LZ-RBUA_Payments_*-InternalC"
  zone            = "eu-central-1c"
  security_groups = ["ad", "rdp", "${dependency.sg.outputs.security_group_name}", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-0380ga0u0hh2ye" })
}
