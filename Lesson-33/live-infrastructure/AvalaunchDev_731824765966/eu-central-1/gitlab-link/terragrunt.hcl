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
  vpc_id     = "vpc-09a74db90a21bf6f1"
  subnet_ids = [
    "subnet-08bfb25d49c4b6a92"
  ]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-0794310664259cd84"
  provider_account_alias = "gitlab-avalaunch"
  dns_names = [
    "gitlab.avalaunch.aval"
  ]

  description = "PrivateLink to the gitlab.avalaunch.aval in the common account"
  tags = {
    "Environment" = "dev"
  }
}
