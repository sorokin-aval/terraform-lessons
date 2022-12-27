include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-iam.git//?ref=v3.0.0"
}
dependency "project_bucket" {
  config_path  = "../iam_policy/s3/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/mock_policy_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}
dependency "project_sources" {
  config_path  = "../iam_policy/sources/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/mock_policy_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}
dependency "project_lakeformation" {
  config_path  = "../iam_policy/lakeformation/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/mock_policy_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  # Automatically load common variables from parent hcl
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  role_name      = "${local.project_vars.locals.project_prefix}"
}

inputs = {
  prefix                = local.project_vars.locals.project_prefix
  create_saml_role      = true
  role_name             = local.role_name
  max_session_duration  = 43200
  description           = "This role for team members usage of Athena"
  tags                  = local.tags_map
  managed_policies_arns = [
    "arn:aws:iam::${local.aws_account_id}:policy/${local.project_vars.locals.project_prefix}-lakeformation",
    dependency.project_sources.outputs.arn,
    dependency.project_bucket.outputs.arn
  ]
  oidc_providers = {
    avalaunch_prod = {
      provider_arn               = local.account_vars.locals.oidc_avalaunch_prod_arn
      namespace_service_accounts = [
        "data-rr-prod:app-prod-data-rr"
      ]
    }
  }
}
