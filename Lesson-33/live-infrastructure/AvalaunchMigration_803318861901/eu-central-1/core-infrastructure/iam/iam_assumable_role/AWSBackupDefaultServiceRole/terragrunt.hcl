include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.common_tags.locals.common_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  module_tags = {
    Role = local.role_name,
    Name = local.role_name
  }
  role_name = "${basename(get_terragrunt_dir())}"
}

inputs = {
  create_role             = true
  create_instance_profile = true
  role_path               = "/service-role/"
  role_name               = local.role_name
  description             = "Provides AWS Backup permission to create and restore backups on your behalf across AWS services"
  tags                    = merge(local.module_tags, local.tags_map)
  role_requires_mfa       = false
  trusted_role_services = [
    "backup.amazonaws.com"
  ]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  ]
}
