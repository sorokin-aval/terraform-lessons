# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "R-INFO"
      "business:product-project"   = "R-INFO"
      "business:team"              = "MARVEL team"
      "business:product-owner"     = "serhii.bondar@raiffeisen.ua"
      "business:emergency-contact" = "oleksandr.zagornyi@raiffeisen.ua"
      "business:cost-center"       = "834"
      "ea:application-name"        = "Raiffeisen-Info"
      "ea:application-id"          = "21194"
    }
  )
}
