# Set list of tags that can be used in child configurations

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals.common_tags,
    {
      Project                    = "${basename(get_terragrunt_dir())}",
      product                    = "${basename(get_terragrunt_dir())}",
      "ea:shared-service"        = false,
      "business:product-owner"   = "sergii.ovsenko@raiffeisen.ua",
      "business:product-project" = "retail-reporting",
      "business:team"            = "data-rr"
    })
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  mock_role       = "rbua-data-test-restrict-role"
  resource_prefix = lower("${local.project_tags.entity}-${local.project_tags.domain}-${local.project_tags["security:environment"]}")
  project_prefix  = lower("${local.resource_prefix}-${local.project_tags.Project}")
}
