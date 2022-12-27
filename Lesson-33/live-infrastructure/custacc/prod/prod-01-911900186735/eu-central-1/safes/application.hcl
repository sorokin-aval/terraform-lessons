# IT Customers and Account Services Delivery 
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "SAFES"
      "business:product-project"   = "SAFES"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "valeriy.parkhomchuk@raiffeisen.ua"
      "business:cost-center"       = "741"
      "ea:application-name"        = "Safes"
      "ea:application-id"          = "14700"
      "application_role"           = "HO-BAPP-SAFE"
      "Patch Group"                = "WinServers"

    }
  )
}
