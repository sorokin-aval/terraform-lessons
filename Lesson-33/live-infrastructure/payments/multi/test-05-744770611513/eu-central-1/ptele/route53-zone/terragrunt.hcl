include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/route53-zone.hcl")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = "${basename(dirname(find_in_parent_folders("route53-zone")))}.${local.account_vars.locals.domain}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  zones = {
    "${local.name}" = {
      comment = "Zone for ${local.name}"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        },
        # comment this on first route53-zone apply
        {
          vpc_id     = "vpc-0f00f1b872ab5dff9"
          vpc_region = "eu-central-1"
        },
        {
          vpc_id     = "vpc-0a09c4cc246243dfc"
          vpc_region = "eu-central-1"
        }
      ]
      tags = local.account_vars.locals.tags
    }
  }
}
