# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                  = "CUSTACC-shared"
      "business:product-project" = "CUSTACC-shared"
      "business:team"              = "DevOps teams"
      "business:product-owner"     = "dmitriy.andreev@raiffeisen.ua"
      "business:emergency-contact" = "oleh.hrechanyi@raiffeisen.ua"
      "business:cost-center" = "653"
#      "ea:application-name"      = "CUSTACC-shared"
#      "ea:application-id"        = ""
    }
  )
}
