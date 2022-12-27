include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//private-link-consumer?ref=consumer_v0.0.1"
}

inputs = {
  vpc_id     = "vpc-0db2a458b42ad4e03"
  subnet_ids = [
    "subnet-0aceec27be2a137b2",
  ]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-0794310664259cd84"
  provider_account_alias = "gitlab-avalaunch"
  dns_names = [
    "gitlab.avalaunch.aval"
  ]

  description = "PrivateLink to the gitlab.avalaunch.aval in the common account"
  tags = {
    "Environment" = "Prod"
  }
}
