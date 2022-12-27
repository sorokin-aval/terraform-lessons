include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals.common_tags
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-crossplane.git?ref=v1.0.1"
}

dependency "eks" {
  config_path = "../eks"

  # Used for succesful first plan run
  mock_outputs = {
    oidc_provider_arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  vault_address       = "https://vault.prod.avalaunch.aval"
  eks_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url

  tags = local.tags_map
}