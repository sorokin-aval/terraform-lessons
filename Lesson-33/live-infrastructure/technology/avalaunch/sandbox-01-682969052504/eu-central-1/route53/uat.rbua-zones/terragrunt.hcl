include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

dependency "vpc" {
  # Hardcode!
  config_path = "../../imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.9.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map = local.common_tags.locals
}

inputs = {
  zones = {
    "uat.rbua" = {
      comment = "UAT zone for applications"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id
        },
        {
          vpc_id = "vpc-0f00f1b872ab5dff9"
        }
      ]
      tags = local.tags_map
    },
    "uat.rinfo.rbua" = {
      comment = "R-Info UAT zone for applications"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id
        },
        {
          vpc_id = "vpc-0f00f1b872ab5dff9"
        }
      ]
      tags = local.tags_map
    },
    "dev.rinfo.rbua" = {
      comment = "Dev zone for applications"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id
        },
        {
          vpc_id = "vpc-0f00f1b872ab5dff9"
        }
      ]
      tags = local.tags_map
    },
    "preprod.rinfo.rbua" = {
      comment = "Preprod zone for applications"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id
        },
        {
          vpc_id = "vpc-0f00f1b872ab5dff9"
        }
      ]
      tags = local.tags_map
    }
  }
}
