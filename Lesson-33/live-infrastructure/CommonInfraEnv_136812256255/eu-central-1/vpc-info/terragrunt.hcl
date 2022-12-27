include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-info.git?ref=v1.1.0"
}

inputs = {
  zone_vpc_filter_tag_key   = "Name"
  zone_vpc_filter_tag_value = "LZ-AVAL_COMMON_TEST-VPC"
  app_subnets_names_filter  = "*Internal*"
}
