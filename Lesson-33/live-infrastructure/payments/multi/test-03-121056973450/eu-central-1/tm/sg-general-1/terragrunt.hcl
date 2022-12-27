include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/sg_common.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name                = "general-tm-1"
  ingress_cidr_blocks = local.account_vars.locals.ips["general-tm-1"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 1521
      to_port     = 1575
      protocol    = "tcp"
      description = "general-tm-1"
    }
  ]
}
