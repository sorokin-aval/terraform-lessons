locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "business:product-project" = basename(get_terragrunt_dir())
      "ea:application-name"      = "BCPay"
      "ea:application-id"        = "15087"
      "product"                  = "BCPAY"
    }
  )
}
