# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                    = "CRM"
      "business:product-project"   = "CRM"
      "business:team"              = "SFT Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "yuliia.prisych@raiffeisen.ua"
      "business:cost-center"       = "741"
      "ea:application-name"        = "CRM (aCRM D365)"
      "ea:application-id"          = "17718"
      "application_role"           = "HO-BAPP-CRM"
    }
  )
}
