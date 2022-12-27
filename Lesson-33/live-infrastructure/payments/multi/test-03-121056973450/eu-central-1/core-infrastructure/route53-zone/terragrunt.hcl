include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/route53-zone.hcl")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  zones = {
    "test.payments.rbua" = {
      comment = "Zone for test.payments.rbua"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        },
        {
          vpc_id     = "vpc-0f00f1b872ab5dff9"
          vpc_region = "eu-central-1"
        }
      ]
      tags = local.account_vars.locals.tags
    }
  }
}
