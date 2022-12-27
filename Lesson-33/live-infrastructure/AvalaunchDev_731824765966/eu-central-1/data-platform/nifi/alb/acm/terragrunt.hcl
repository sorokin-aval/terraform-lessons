terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//payments/acm-certificate?ref=payments/main"
}

include "envcommon" {
  path   = find_in_parent_folders("global.hcl")
  expose = true
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  common_tags      = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map         = local.project_vars.locals.project_tags
  hosted_zone_name = "${local.tags_map.Environment}.${local.tags_map.Domain}.${local.tags_map.Nwu}"
}

inputs = {
  pca_arn = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"

  certificates = {
    nifi = {
      domain_name       = "nifi.${local.hosted_zone_name}"
      alternative_names = [
        "nifi.${local.hosted_zone_name}",
        "nifi-registry.${local.hosted_zone_name}",
        "trino.${local.hosted_zone_name}",
        "superset.${local.hosted_zone_name}"
      ]
    },
  }

  tags = local.tags_map
}