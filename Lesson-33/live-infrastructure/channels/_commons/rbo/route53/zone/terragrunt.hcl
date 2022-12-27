terraform {
  source = local.account_vars.sources_r53_zone_with_common
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  tags         = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_adm })
}

inputs = {
  tags = local.tags
  zone_account_id = local.account_vars.aws_account_id

  zones = {
    "${local.account_vars.domain}" = {
      name = "${local.account_vars.domain}"
      comment = "Zone for ${local.account_vars.domain}"
    }
  }
}
