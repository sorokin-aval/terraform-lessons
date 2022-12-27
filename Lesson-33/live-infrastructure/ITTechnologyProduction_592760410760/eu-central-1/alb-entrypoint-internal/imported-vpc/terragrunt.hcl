include {
  path = find_in_parent_folders()
}

locals {
  imported_vpc_module_source = {
    url = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//imported-vpc",
    ref = "main"
  }
}

terraform {
#   source = "${local.imported_vpc_module_source.url}?ref=${local.imported_vpc_module_source.ref}"
    source = "../../../../../../ua-avalaunch-terraform-modules/imported-vpc/"
}

inputs = {
  subnets_names = ["LZ-RBUA_Technology_Prod-InternalC", "LZ-RBUA_Technology_Prod-InternalB", "LZ-RBUA_Technology_Prod-InternalA"]
}