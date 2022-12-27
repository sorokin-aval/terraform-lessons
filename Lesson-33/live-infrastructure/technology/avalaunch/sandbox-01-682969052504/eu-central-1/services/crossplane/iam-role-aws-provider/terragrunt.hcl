include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role-with-oidc?ref=v5.1.0"
}

dependency "eks" {
  config_path = "../../../eks"

  # Used for succesful first plan run
  mock_outputs = {
    oidc_provider_arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

dependency "iam-policy-aws-provider" {
  config_path = "../iam-policy-aws-provider"

  # Used for succesful first plan run
  mock_outputs = {
    arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  tags_map = local.common_tags.locals.common_tags

  role_name        = "crossplane-aws-provider"
  sa_k8s_namespace = "crossplane"
  # Created by crossplane to get it run: kubectl get sa -n crossplane | grep aws
  sa_k8s_name = "aws-*"
}

inputs = {
  create_role = true

  role_name        = local.role_name
  role_description = "IAM role used by crossplane aws provider"
  tags             = local.tags_map

  provider_url = dependency.eks.outputs.cluster_oidc_issuer_url
  role_policy_arns = [
    dependency.iam-policy-aws-provider.outputs.arn
  ]
  oidc_subjects_with_wildcards = ["system:serviceaccount:${local.sa_k8s_namespace}:${local.sa_k8s_name}"]
}