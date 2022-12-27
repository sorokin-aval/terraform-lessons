include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/efs.hcl")
}


# For Restriction SG rules
dependency "efs_source_sg" { config_path = find_in_parent_folders("sg/access_admin") }

# Fix tag filtering & allowed_cidr_blocks
locals {
  account_vars                   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                       = read_terragrunt_config(find_in_parent_folders("project.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
 # Create at one AZ
  availability_zone_name         = "eu-central-1a"
  subnets                        = [ dependency.vpc.outputs.app_subnets.ids["1"] ]
 # Restriction SG rules
  allowed_security_group_ids     = [ dependency.efs_source_sg.outputs.security_group_id ]
  allowed_cidr_blocks            = local.account_vars.locals.ips["dms_dc"]
 # Fix tag filtering
  tags                           = merge(local.tags_map.locals.tags, { product = "DMS-LCA DMS-APS" })
}