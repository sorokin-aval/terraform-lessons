locals {
  name = basename(get_terragrunt_dir())
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals.tags,
    {
      "business:product-project" = basename(get_terragrunt_dir())
      "ea:application-name"      = "Forex Session"
      "ea:application-id"        = "15097"
      "product"                  = "FX-SESSION"
    }
  )
}
