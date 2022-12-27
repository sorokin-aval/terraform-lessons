# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                  = "CMD"
      "business:product-project" = "CMD"
      "business:team"              = "CMD Team"
      "business:product-owner"     = "vitaliy.voinalovych@raiffeisen.ua"
      "business:emergency-contact" = "vitaliy.voinalovych@raiffeisen.ua"
      "business:cost-center" = "723"
      "ea:application-name"      = "CMD"
      "ea:application-id"        = "147232"
      "application_role"        = "HO-BAPP-CMD"
    }
  )
}
