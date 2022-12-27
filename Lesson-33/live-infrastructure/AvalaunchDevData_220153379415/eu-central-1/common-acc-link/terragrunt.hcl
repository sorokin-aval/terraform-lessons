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
  vpc_id     = "vpc-0130574d285276db6"
  subnet_ids = ["subnet-0f60ac8009a8da23f", "subnet-0cb9943bc5b8f2311"]
  
  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-040fc8e8aa901429d"
  provider_account_alias = "common"
  dns_names              = ["harbor.avalaunch.aval", "thanos-receive.avalaunch.aval", "thanos.avalaunch.aval", "dex.common.avalaunch.aval"]

  description            = "PrivateLink to the common account"
  tags = {
    "Environment" = "dev"
  }
}
