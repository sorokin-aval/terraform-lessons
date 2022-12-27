# Set list of tags that can be used in child configurations
locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags    = merge(local.common_tags.locals.common_tags, { Project = "${basename(get_terragrunt_dir())}" })
  resource_prefix = lower("${local.project_tags.entity}-${local.project_tags.domain}-${local.project_tags["security:environment"]}")
  project_prefix  = lower("${local.resource_prefix}-${local.project_tags.Project}")
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
