dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  zones = {
    "${local.account_vars.locals.domain}" = {
      comment = "Zone for ${local.account_vars.locals.domain}"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        }
      ]
      tags = local.account_vars.locals.tags
    }
  }
}
