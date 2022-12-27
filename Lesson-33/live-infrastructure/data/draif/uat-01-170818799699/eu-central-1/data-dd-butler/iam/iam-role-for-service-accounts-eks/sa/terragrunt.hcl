include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependency "project_bucket" {
  config_path  = "../../iam_policy/s3/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/mock_policy_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}
dependency "project_sources" {
  config_path  = "../../iam_policy/sources/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/mock_policy_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

#dependency "eks" {
#  config_path = "../../../../eks/"
#}

locals {
  # Automatically load common variables from parent hcl
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  module_tags    = {
    Role = local.role_name,
    Name = local.role_name
  }
  role_name = "${local.tags_map.Nwu}-${local.tags_map.Tech_domain}-sa"

}

inputs = {
  create_role    = true
  role_name      = local.role_name
  description    = "${basename(get_terragrunt_dir())} policy for EKS serviceaccount. Created with Terragrunt"
  tags           = merge(local.module_tags, local.tags_map)
  oidc_providers = {
    ex = {
      provider_arn               = "arn:aws:iam::{$local.aws_account_id}:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/4EB695BDD7A1CA4FB09E962C75FB90CA"
      #TODO: dependency.eks.outputs.oidc_provider_arn eks module does not have tfswitch, so have  tf versions mismatch
      namespace_service_accounts = [
        "${local.tags_map.Tech_domain}-${local.tags_map.Environment}:app-${local.tags_map.Environment}-airflow"
      ]
    }
  }
  role_policy_arns = {
    sources        = dependency.project_sources.outputs.arn,
    project_bucket = dependency.project_bucket.outputs.arn
  }
}
