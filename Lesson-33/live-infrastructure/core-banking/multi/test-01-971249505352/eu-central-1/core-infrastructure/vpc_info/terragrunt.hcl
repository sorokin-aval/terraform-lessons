include "root" {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

locals {
  # Automatically load common tags from parent hcl
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-info.git//?ref=v1.1.0"
} 

