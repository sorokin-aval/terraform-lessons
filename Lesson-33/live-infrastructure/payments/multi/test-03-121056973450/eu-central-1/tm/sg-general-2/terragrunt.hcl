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

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name                = "general-tm-2"
  ingress_cidr_blocks = concat(local.account_vars.locals.ips["general-tm-2"], local.account_vars.locals.ips["mbank"], dependency.vpc.outputs.db_subnet_cidr_blocks)
  ingress_with_cidr_blocks = [
    {
      from_port   = 1521
      to_port     = 1575
      protocol    = "tcp"
      description = "general-tm-2"
    }
  ]
}
