# Set list of tags that can be used in child configurations

locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals, { Project = "${basename(get_terragrunt_dir())}" })
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  kms_key_id   = "arn:aws:kms:eu-central-1:665998680203:key/64f5d8b9-f80b-4a15-b11f-d5fb47e48d46"

}
