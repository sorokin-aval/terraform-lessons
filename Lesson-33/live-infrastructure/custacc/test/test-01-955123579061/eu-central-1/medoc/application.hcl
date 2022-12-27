# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "MEDOC"
      "business:product-project"   = "MEDOC"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "taras.vus@raiffeisen.ua"
      "business:cost-center"       = "826"
      "ea:application-name"        = "MEDOC"
      "ea:application-id"          = "147232"
      "application_role"           = "HO-BAPP-MEDOC"
    }
  )
}
