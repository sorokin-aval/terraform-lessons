#custacc  !
include {
  path = find_in_parent_folders()
}

locals {
  init           = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.aws_account_id}")
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars    = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  baseline_ref   = "v3.0.1"
}

iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=${local.baseline_ref}"
}

inputs = {
  tags = local.app_vars.locals.tags
  aws_win_patch_enabled = true
}
