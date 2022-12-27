include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}

dependency "iam_role" {
  config_path  = "../../iam/iam_role/dl-team/"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.mock_role}"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

dependency "lakeformation_role" {
  config_path  = "../../../core-infrastructure/lakeformation-account/"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.mock_role}"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-lakeformation.git//modules/lakeformation-role?ref=lakeformation_v0.3.1"
}

locals {
  # Hardcode values
  layer = "integration"

  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))

  # Extract out exact variables for reuse
  tags_map                = local.project_vars.locals.project_tags
  mock_role               = local.project_vars.locals.mock_role
  aws_account_id          = include.account.locals.aws_account_id
  resource_prefix         = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}"
  layered_resource_prefix = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}-${local.tags_map.Project}"
}

inputs = {
  enforce_workgroup_configuration = true
  lakeformation_role_arn          = dependency.lakeformation_role.outputs.iam_role
  grantee_principal               = dependency.iam_role.outputs.saml_role_arn
  resource_prefix                 = local.resource_prefix
  layered_resource_prefix         = local.layered_resource_prefix
  tags                            = local.tags_map
}
