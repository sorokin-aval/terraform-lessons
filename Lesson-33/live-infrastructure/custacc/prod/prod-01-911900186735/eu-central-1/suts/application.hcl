# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "SUTS"
      "business:product-project"   = "SUTS"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "yuliia.prisych@raiffeisen.ua"
      "business:cost-center"       = "741"
      "ea:application-name"        = "Suts"
      "ea:application-id"          = "15205"
      application_role             = "HO-BAPP-SUTS"
    }
  )
}
