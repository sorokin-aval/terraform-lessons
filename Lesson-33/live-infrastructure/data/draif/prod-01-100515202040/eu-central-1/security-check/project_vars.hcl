# Set list of tags that can be used in child configurations

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals.common_tags, { Project = "${basename(get_terragrunt_dir())}" })
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  mock_role    = "rbua-data-test-restrict-role"
}
