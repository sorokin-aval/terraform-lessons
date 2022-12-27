include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

dependencies {
  paths = ["../../iam_policy/dl-role-policy/"]
}

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  resource_prefix = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}"
  source_map      = local.source_vars.locals
  tags_map        = local.project_vars.locals.project_tags
  aws_account_id  = include.account.locals.aws_account_id
  module_tags     = {
    Role = local.resource_prefix,
    Name = local.resource_prefix
  }
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

inputs = {
  create_role          = true
  role_name            = local.resource_prefix
  max_session_duration = 43200
  description          = "This role provides full access to RDS service"
  tags                 = merge(local.module_tags, local.tags_map)
  provider_id          = "arn:aws:iam::${local.aws_account_id}:saml-provider/RBI-PingFederate"
  role_policy_arns     = [
    "arn:aws:iam::${local.aws_account_id}:policy/${local.resource_prefix}-policy"
  ]

}
