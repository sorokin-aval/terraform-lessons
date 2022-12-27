terraform {
  source = local.account_vars.locals.sources["quotas"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

locals {
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  service_quotas  = local.account_vars.locals.service_quotas
}