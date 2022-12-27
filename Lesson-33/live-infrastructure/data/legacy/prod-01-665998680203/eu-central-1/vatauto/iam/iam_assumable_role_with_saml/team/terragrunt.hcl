include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependency "ec2_iam_policy" {
  config_path = "../../iam_policy/ec2/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/tmp-iam-policy"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  module_tags = {
    Role = local.role_name,
    Name = local.role_name
  }
  role_name = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-${basename(get_terragrunt_dir())}"
}

inputs = {
  create_role          = true
  role_name            = local.role_name
  max_session_duration = 43200
  description          = "This role for legacy prod archive access"
  tags                 = merge(local.module_tags, local.tags_map)
  provider_id          = "arn:aws:iam::${local.aws_account_id}:saml-provider/RBI-PingFederate"
  role_policy_arns = [
    dependency.ec2_iam_policy.outputs.arn
  ]
}
