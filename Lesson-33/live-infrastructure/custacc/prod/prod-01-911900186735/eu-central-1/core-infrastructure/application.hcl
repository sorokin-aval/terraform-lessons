# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                  = "CUSTACC-shared"
      "business:product-project" = "CUSTACC-shared"
      "business:team"              = "DevOps teams"
      "business:product-owner"     = "mykhailo.ovcharenko@raiffeisen.ua"
      "business:emergency-contact" = "bogdan.shipunov@raiffeisen.ua"
      "business:cost-center" = "741"
#      "ea:application-name"      = "CUSTACC-shared"
#      "ea:application-id"        = ""
       "application_role" = "CUSTACC-shared"
    }
  )
}
