include {
  path = find_in_parent_folders()
}
locals {
  init         = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.account_vars.aws_account_id}")
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}
#iam_role = local.account_vars.iam_role
iam_role = "arn:aws:iam::${local.account_vars.aws_account_id}:role/BootstrapRole"

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v2.14.7"
}

inputs = {
  tags = local.common_tags.locals.default_tag
  zone_vpc_filter_tag_key   = "Name"
  zone_vpc_filter_tag_value = "LZ-RBUA_CORE_Network_HUB_PROD-VPC"
}
