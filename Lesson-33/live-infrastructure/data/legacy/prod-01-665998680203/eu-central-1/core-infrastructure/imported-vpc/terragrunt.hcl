include "root" {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  imported_vpc_module_source = {
    url = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info",
    ref = "main"
  }
}

terraform {
  source = "${local.imported_vpc_module_source.url}?ref=${local.imported_vpc_module_source.ref}"
}

inputs = {}
