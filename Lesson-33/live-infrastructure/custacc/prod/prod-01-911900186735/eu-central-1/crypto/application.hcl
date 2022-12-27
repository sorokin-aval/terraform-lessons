# IT Customers and Account Services Delivery 
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "CRYPTO"
      "business:product-project"   = "CRYPTO"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "valeriy.parkhomchuk@raiffeisen.ua"
      "business:cost-center"       = "826"
      "ea:application-name"        = "Crypto"
      "ea:application-id"          = "21336"
      "application_role"           = "KV-SW-CRYPTO"
    }
  )
}
