include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  imported_vpc_module_source = {
    url = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//imported-vpc",
    ref = "main"
  }
}

terraform {
  source = "${local.imported_vpc_module_source.url}?ref=${local.imported_vpc_module_source.ref}"
}

inputs = {
  subnets_names = ["LZ-AVAL_AvalaunchSandbox_DEV_03-InternalA", "LZ-AVAL_AvalaunchSandbox_DEV_03-InternalB"]
}