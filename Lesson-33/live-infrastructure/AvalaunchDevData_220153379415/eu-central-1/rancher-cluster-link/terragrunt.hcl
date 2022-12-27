include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//private-link-consumer?ref=consumer_v0.0.1"
}

inputs = {
  vpc_id     = "vpc-0130574d285276db6"
  subnet_ids = ["subnet-0f60ac8009a8da23f", "subnet-0cb9943bc5b8f2311"]
  
  provider_service_name  = "com.amazonaws.vpce.eu-central-1.vpce-svc-0ad11b1bd83f53489"
  provider_account_alias = "rancher"
  dns_names              = ["rancher.avalaunch.aval"]

  description            = "PrivateLink to the Rancher cluster"
  tags = {
    "Environment" = "Dev"
  }
}
