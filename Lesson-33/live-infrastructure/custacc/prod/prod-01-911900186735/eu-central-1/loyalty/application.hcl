# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "LOYALTY-2"
      "business:product-project"   = "LOYALTY-2"
      "business:team"              = "MARVEL Team"
      "business:product-owner"     = "serhii.bondar@raiffeisen.ua"
      "business:emergency-contact" = "yuliia.prisych@raiffeisen.ua"
      "business:cost-center"       = "826"
      "ea:application-name"        = "Loyality 2.0"
      "ea:application-id"          = "21196"
      "application_role"           = "HO-BAPP-LOYALTY"
    }
  )
}
