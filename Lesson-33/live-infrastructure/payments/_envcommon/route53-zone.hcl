dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.9.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = "${basename(dirname(find_in_parent_folders("route53-zone")))}.${local.account_vars.locals.domain}"
}

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
        }
      ]
      tags = local.account_vars.locals.tags
    }
  }
}
