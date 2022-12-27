locals {
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("domain.hcl")).locals.tags,
    {
      "security:confidentiality"   = "3 - Confidential"
      "internet-faced"             = "false"
      "product"                    = "DMS-LCA,DMS-APS"
      "business:team"              = "DMS team"
      "business:product-project"   = "DMS"
      "business:product-owner"     = "dmitriy.andreev@raiffeisen.ua"
      "business:emergency-contact" = "dmitriy.andreev@raiffeisen.ua"
      "ea:application-name"        = "DMS-LCA"
      "ea:application-id"          = "147241"
    }
  )
}