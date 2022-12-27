include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vault?ref=vault_v1.0.0"
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
  ### Global configuration ###
  zone                              = "dev"
  component_name                    = "vault"

  ### EKS target cluster role
  ### You can find it in module.eks.worker_iam_role_name output
  worker_iam_role                   = "avalaunch-dev20220223165159975400000009"
}
