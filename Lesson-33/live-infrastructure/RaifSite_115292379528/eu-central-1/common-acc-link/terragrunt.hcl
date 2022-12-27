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
  vpc_id     = "vpc-054b3e5df66797f26"
  subnet_ids = ["subnet-09d371007db63067a", "subnet-012bad00e3921049a"]

  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-040fc8e8aa901429d"
  provider_account_alias = "common"
  dns_names              = ["harbor.avalaunch.aval", "thanos-receive.avalaunch.aval", "thanos.avalaunch.aval", "dex.common.avalaunch.aval"]

  description = "PrivateLink to the common account"
  tags = {
    "Environment" = "dev"
  }
}
