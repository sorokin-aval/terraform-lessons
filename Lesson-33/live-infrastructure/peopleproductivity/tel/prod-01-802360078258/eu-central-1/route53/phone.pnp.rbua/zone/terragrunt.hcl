include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.9.0"
}

locals {
  envcommon     = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map      = merge(local.common_tags.locals)

  zone_name     = basename(dirname(get_terragrunt_dir()))
}

inputs = {
  zones = {
    "${local.zone_name}" = {
      comment = "Zone ${local.zone_name}"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        },
        # {
        #   # TODO - Hardcoded, replace in future release
        #  # vpc_id = "vpc-0f00f1b872ab5dff9"
        # }
      ]
      tags = local.tags_map
    }
  }
}
