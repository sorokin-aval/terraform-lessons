# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "core-infrastructure"
      "business:product-project"   = basename(get_terragrunt_dir())
      "business:team"              = "DevOps team"
      "business:product-owner"     = "mykhailo.ovcharenko@raiffeisen.ua"
      "business:emergency-contact" = "bogdan.shipunov@raiffeisen.ua"
      "business:cost-center"       = "741"
      "ea:application-name"        = "ToBeDefined"
      "ea:application-id"          = "00000"
      application_role             = "CUSTACC-shared"
    }
  )
}
