include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}
locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "${include.envcommon.locals.base_source_url}//imported-vpc"
}
inputs = {
  subnets_names = [
    "LZ-RBUA_DRAIF_Prod_01-RestrictedA",
    "LZ-RBUA_DRAIF_Prod_01-RestrictedB",
    "LZ-RBUA_DRAIF_Prod_01-RestrictedC",
    "LZ-RBUA_DRAIF_Prod_01-InternalA",
    "LZ-RBUA_DRAIF_Prod_01-InternalB",
    "LZ-RBUA_DRAIF_Prod_01-InternalC",
    "CGNATSubnet1",
    "CGNATSubnet2",
    "CGNATSubnet3"
  ]
}
