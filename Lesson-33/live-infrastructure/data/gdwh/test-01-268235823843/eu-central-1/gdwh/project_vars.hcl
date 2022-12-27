locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals.common_tags, {
    Project                      = "${basename(get_terragrunt_dir())}",
    "business:team"              = "GDWH"
    "business:product-project"   = "GDWH"
    "business:product-owner"     = "mykola.pavlyk@raiffeisen.ua"
    "business:emergency-contact" = "mykola.pavlyk@raiffeisen.ua"
    product                      = "GDWH"

  })
  resource_prefix = lower("${local.project_tags.entity}-${local.project_tags.domain}-${local.project_tags["security:environment"]}-${local.project_tags.product}-test")
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
