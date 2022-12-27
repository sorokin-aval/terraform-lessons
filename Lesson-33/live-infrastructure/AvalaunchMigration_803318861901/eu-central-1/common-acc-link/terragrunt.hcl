include {
  path = find_in_parent_folders()
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
    "Environment" = "Prod"
  }
}
