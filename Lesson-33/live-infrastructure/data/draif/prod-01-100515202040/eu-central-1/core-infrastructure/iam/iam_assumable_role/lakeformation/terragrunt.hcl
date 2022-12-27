include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true

}

dependencies {
  paths = ["../../iam_policy/lakeformation-policy/"]
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  source_vars = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.common_tags.locals
  aws_account_id = include.account.locals.aws_account_id

  module_tags = {
    Role = local.role_name,
    Name = local.role_name
  }
  role_name = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${basename(get_terragrunt_dir())}"
}

inputs = {
  create_role           = true
  role_name             = local.role_name
  max_session_duration  = 43200
  description           = "This role provides access for AWS S3 buckets from Lake Formation"
  tags                  = merge(local.module_tags, local.tags_map)
  role_requires_mfa     = false
  trusted_role_services = [
    "lakeformation.amazonaws.com"
  ]
  custom_role_policy_arns = [
    "arn:aws:iam::${local.aws_account_id}:policy/${local.role_name}-policy"
  ]
}
