# IT Customers and Account Services Delivery 
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "KRD-WEB"
      "business:product-project"   = "KRD-WEB"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "rostyslav.tomashivskyi@raiffeisen.ua"
      "business:cost-center"       = "826"
      "ea:application-name"        = "KRD Web"
      "ea:application-id"          = "15109"
      "application_role"           = "HO-BAPP-KRD-WEB"
    }
  )
}
