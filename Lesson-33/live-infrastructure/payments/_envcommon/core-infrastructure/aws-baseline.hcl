terraform {
  source = local.account_vars.locals.sources["baseline"]
}

locals {
  init           = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.aws_account_id}")
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map       = local.account_vars.locals.tags
  baseline_ref   = substr(local.account_vars.locals.sources["baseline"], -7, -1)
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/BootstrapRole"

inputs = {
  tags             = local.tags_map
  baseline-version = local.baseline_ref
}
