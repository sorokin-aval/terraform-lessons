include {
  path = find_in_parent_folders()
}

locals {
  //  init           = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.aws_account_id}")
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars    = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  baseline_ref   = "v3.0.2"
}

iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=${local.baseline_ref}"
}

inputs = {
  tags             = local.common_tags.locals
  baseline-version = local.baseline_ref
  dbre = {
    enabled               = false
    managed_policies_arns = []
    trusted_role_arns     = []
  }
  developer = {
    enabled               = false
    managed_policies_arns = []
    trusted_role_arns     = []
    policy                = []
  }
  devops = {
    enabled               = false
    managed_policies_arns = []
    trusted_role_arns     = []
  }
  l2support = {
    enabled               = false
    managed_policies_arns = []
    trusted_role_arns     = []
    max_session_duration  = "43200"
  }
  platformops = {
    enabled               = false
    managed_policies_arns = []
    trusted_role_arns     = []
    max_session_duration  = "43200"
  }
}
