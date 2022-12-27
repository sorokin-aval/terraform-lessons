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
  subnet_ids = ["subnet-04f3fe80c2eff25d3", "subnet-08bfb25d49c4b6a92"]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-0ad11b1bd83f53489"
  provider_account_alias = "rancher"
  dns_names              = ["rancher.avalaunch.aval"]

  description = "PrivateLink to the Rancher cluster"
  tags = {
    "Environment" = "Dev"
  }
}
