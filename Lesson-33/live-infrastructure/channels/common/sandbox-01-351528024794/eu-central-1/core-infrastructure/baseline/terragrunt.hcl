include {
  path = find_in_parent_folders()
}
locals {
  init           = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.aws_account_id}")
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars    = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"

terraform {
  source = local.account_vars.locals.sources_baseline
}

inputs = {
  tags                  = merge(local.common_tags.locals)
}