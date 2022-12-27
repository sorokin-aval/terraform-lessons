# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "SFINCS"
      "business:product-project"   = "SFINCS"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "svitlana.cheremnykh@raiffeisen.ua"
      "business:cost-center"       = "741"
      "ea:application-name"        = "Sfincs"
      "ea:application-id"          = "15215"
      "application_role"           = "HO-BAPP-SFINCS"
    }
  )
}
