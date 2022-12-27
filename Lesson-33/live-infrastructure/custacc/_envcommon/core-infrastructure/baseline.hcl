terraform {
  source = local.account_vars.locals.sources["baseline"]
}

locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  init         = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.account_vars.locals.aws_account_id}")
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/BootstrapRole"

inputs = {
  tags = merge(local.common_tags.locals)
}