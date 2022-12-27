include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-core-roles.git//?ref=v0.0.1"
}

inputs = {
  tags = local.common_tags.locals
}
