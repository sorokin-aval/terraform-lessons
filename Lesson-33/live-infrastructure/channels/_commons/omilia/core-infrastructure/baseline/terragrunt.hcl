locals {
  init           = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.aws_account_id}")
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags_map       = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  aws_account_id = local.account_vars.aws_account_id
}

iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"

terraform {
  source = local.account_vars.sources_baseline
}

inputs = {
  tags                  = local.tags_map,
  baseline-version      = local.account_vars.baseline_ref
  aws_win_patch_enabled = local.account_vars.aws_win_patch_enabled
}
