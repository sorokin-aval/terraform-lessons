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
    "subnet-0f7dcd2cce5c287a8",
    "subnet-0aceec27be2a137b2",
  ]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-0ad11b1bd83f53489"
  provider_account_alias = "rancher"
  dns_names              = ["rancher.avalaunch.aval"]

  description = "PrivateLink to the Rancher cluster"
  tags = {
    "Environment" = "Prod"
  }
}
