include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "iam_policy_access" {
  config_path  = "../../iam_policy/data-engineer-access/"
  mock_outputs = {
    mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
    arn                                     = "arn:aws:iam::${local.aws_account_id}:policy/test"
  }
}

dependency "iam_policy_dl" {
  config_path  = "../../iam_policy/data-engineer-dl/"
  mock_outputs = {
    mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
    arn                                     = "arn:aws:iam::${local.aws_account_id}:policy/test"
  }
}

// dependency "iam_policy_ssm" {
//   config_path = "../../iam_policy/data-engineer-ssm/"
//   mock_outputs = {
//     mock_outputs_allowed_terraform_commands = ["plan"]
//     arn                                     = "arn:aws:iam::${local.aws_account_id}:policy/test"
//   }
// }

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  project_prefix = local.project_vars.locals.project_prefix
  # module_tags    = {
  #   Role = local.resource_prefix,
  #   Name = local.resource_prefix
  # }
  # resource_prefix = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-data-engineer"
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

inputs = {
  create_role          = true
  role_name            = "${local.project_prefix}-${basename(get_terragrunt_dir())}"
  max_session_duration = 43200
  description          = "This role provides access for data engineers to manage data lake"
  tags                 = local.tags_map
  # tags                 = merge(local.module_tags, local.tags_map)
  provider_id          = "arn:aws:iam::${local.aws_account_id}:saml-provider/RBI-PingFederate"
  role_policy_arns     = [
    dependency.iam_policy_dl.outputs.arn,
    dependency.iam_policy_access.outputs.arn
    // dependency.iam_policy_ssm.outputs.arn
  ]

}
