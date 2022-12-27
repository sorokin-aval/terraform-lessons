include {
  path = find_in_parent_folders()
}
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
iam_role = local.account_vars.iam_role
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//private-link-consumer?ref=consumer_v0.0.1"
}

inputs = {
  vpc_id     = "vpc-09a74db90a21bf6f1"
  subnet_ids = ["subnet-04f3fe80c2eff25d3", "subnet-08bfb25d49c4b6a92"]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-040fc8e8aa901429d"
  provider_account_alias = "common"
  dns_names = [
    "harbor.avalaunch.aval",
    "thanos-receive.avalaunch.aval",
    "thanos.avalaunch.aval",
    "dex.common.avalaunch.aval",
    "nexus.avalaunch.aval"
  ]

  description = "PrivateLink to the common account"
  tags = {
    "Environment" = "dev"
  }
}
