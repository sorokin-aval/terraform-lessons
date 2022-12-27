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
    source = "../../../../../ua-avalaunch-terraform-modules/imported-vpc/"
}

inputs = {
  subnets_names = ["LZ-RBUA_CyberSecurity_General_Prod_04-InternalA", "LZ-RBUA_CyberSecurity_General_Prod_04-InternalB"]
}