dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

terraform { source = local.account_vars.sources_route53_zone }

locals {
  domain       = "registrationauthority.ca"
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  tags         = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_adm })
}

iam_role = local.account_vars.iam_role

inputs = {
  zones = {
    "${local.domain}" = {
      comment = "Zone for ${local.domain}"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        }
      ]
      tags = local.tags
    }
  }
}
