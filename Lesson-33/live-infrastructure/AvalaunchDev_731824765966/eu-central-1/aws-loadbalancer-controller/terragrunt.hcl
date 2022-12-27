include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

dependency "eks" {
  config_path = "../eks"
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-loadbalancer-controller?ref=aws-lb-controller_v1.0.0"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out exact variables for reuse
  env          = local.account_vars.locals.environment
  tags_map     = local.common_tags.locals
}

inputs = {
  cluster_name                     = dependency.eks.outputs.cluster_id
  cluster_identity_oidc_issuer     = dependency.eks.outputs.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = dependency.eks.outputs.oidc_provider_arn
  namespace                        = "infra-tools"

  tags = local.tags_map
}
