# IT Customers and Account Services Delivery
locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "product"                  = "SALESBASE"
      "business:product-project" = "SALESBASE"
      "business:team"              = "Sales Base team"
      "business:product-owner"     = "serhii.bondar@raiffeisen.ua"
      "business:emergency-contact" = "ruslan.korovnychenko@raiffeisen.ua"
      "business:cost-center" = "863"
      "ea:application-name"      = "SalesBase"
      "ea:application-id"        = "18185"
       application_role = "HO-BAPP-SALES-BASE", 
    }
  )
}
