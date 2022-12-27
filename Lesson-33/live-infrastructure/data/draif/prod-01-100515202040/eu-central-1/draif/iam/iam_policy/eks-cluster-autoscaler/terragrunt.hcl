include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependency "eks" {
  config_path = "../../../eks"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.common_tags.locals
  aws_account_id = local.account_vars.locals.aws_account_id
}


inputs = {
  create_role                      = true
  role_name                        = "${basename(get_terragrunt_dir())}"
  description                      = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [dependency.eks.outputs.cluster_id]

  oidc_providers = {
    ex = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = local.tags_map

}
