dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

terraform { source = local.account_vars.sources_route53_zone }

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  tags         = local.tags_map
}

iam_role = local.account_vars.iam_role

inputs = {
  zones = {
    "${local.account_vars.webpromo_domain}" = {
      comment = "Zone for ${local.account_vars.webpromo_domain}"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        }
      ]
      tags = local.tags
    }
  }
}