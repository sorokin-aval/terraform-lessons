include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "iam_role" {
  config_path  = "../iam/iam_role/"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.mock_role}"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

dependency "lakeformation_role" {
  config_path  = "../../core-infrastructure/lakeformation-account/"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::${local.aws_account_id}:role/${local.mock_role}"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-lakeformation.git//modules/lakeformation-role?ref=v1.1.0"
}

locals {
  # Hardcode values
  layer       = "integration"
  bucket_name = "${local.project_vars.locals.resource_prefix}-${local.layer}-${local.tags_map.Project}"

  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = "./modules/lake-formation//"

  # Extract out exact variables for reuse
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  mock_role      = local.project_vars.locals.mock_role
}

inputs = {
  enforce_workgroup_configuration = true
  lakeformation_role_arn          = dependency.lakeformation_role.outputs.iam_role
  athena_bucket                   = local.bucket_name # would be removed in next module version
  bucket                          = local.bucket_name
  grantee_principal               = dependency.iam_role.outputs.saml_role_arn
  key_administrators              = ["arn:aws:iam::803318861901:root"]
  key_service_users               = ["arn:aws:iam::803318861901:root"]
  resource_prefix                 = local.project_vars.locals.project_prefix
  tags                            = local.tags_map
  aws_account_id                  = local.aws_account_id
}
