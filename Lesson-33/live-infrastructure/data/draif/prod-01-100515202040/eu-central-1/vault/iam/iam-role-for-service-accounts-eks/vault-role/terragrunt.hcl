include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependencies {
  paths = ["../../iam_policy/vault-policy/"]
}
dependency "eks" {
  config_path = "../../../../draif/eks/"
}

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
  # TODO: hardcoded role name. Need to import KMS key and refactor.
  role_name = "${local.tags_map.Nwu}-${local.tags_map.Domain}-vault-eks"

}

inputs = {
  create_role    = true
  role_name      = local.role_name
  description    = "${basename(get_terragrunt_dir())} policy for EKS serviceaccount. Created with Terragrunt"
  tags           = merge(local.module_tags, local.tags_map)
  oidc_providers = {
    ex = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "${local.tags_map.Project}:app-${local.tags_map.Environment}-${local.tags_map.Legacy_domain}-${local.tags_map.Project}"
      ]
    }
  }
  role_policy_arns = {
    vault = "arn:aws:iam::${local.aws_account_id}:policy/${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}"
  }
}
