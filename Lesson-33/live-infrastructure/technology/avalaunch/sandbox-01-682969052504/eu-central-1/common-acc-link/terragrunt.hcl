include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git////private-link-consumer?ref=consumer_v0.0.1"
}

inputs = {
  vpc_id     = "vpc-086d8684f7849f950"
  subnet_ids = ["subnet-0aa4bd04a09fa69c0", "subnet-089eb0783d708faf7"]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-040fc8e8aa901429d"
  provider_account_alias = "common"
  dns_names              = ["harbor.avalaunch.aval", "thanos-receive.avalaunch.aval", "thanos.avalaunch.aval"]

  description = "PrivateLink to the common account"
  tags = {
    "Environment" = "Sandbox"
  }
}
