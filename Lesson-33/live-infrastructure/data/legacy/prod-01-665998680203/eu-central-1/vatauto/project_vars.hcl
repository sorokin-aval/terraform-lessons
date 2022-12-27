# Set list of tags that can be used in child configurations

locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals, { Project = "${basename(get_terragrunt_dir())}" })
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  kms_key_id   = "89073488-6f7c-4d72-98e6-e40edf2d85b2"
}
