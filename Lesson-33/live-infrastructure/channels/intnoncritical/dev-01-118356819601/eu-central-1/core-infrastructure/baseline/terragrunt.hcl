include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = local.account_vars.sources_baseline
}

locals {
  init         = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.account_vars.aws_account_id}")
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = "arn:aws:iam::${local.account_vars.aws_account_id}:role/BootstrapRole"

inputs = {
  tags = merge(
    local.tags_map,
    {
      baseline-version = local.account_vars.baseline_ref
    }
  )
  aws_win_patch_enabled           = local.account_vars.aws_win_patch_enabled
  l2support_managed_policies_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}