# Set list of tags that can be used in child configurations
locals {
  tags = {
    ###
    "security:environment"       = "Prod"
    "business:product-project"   = "appstream"
    "map-migrated"               = "null"
    "map-dba"                    = "null"
    "product"                    = "null"
    "ea:application-id"          = "null"
    "ea:application-name"        = "null"
    "PurchaseRequest"            = "710377313"
    ####
    "security:confidentiality"   = "3 - Confidential"
    "business:cost-center"       = "520"
    "business:team"              = "Infrastructure team"
    "business:product-owner"     = "andrii.kovtun@raiffeisen.ua"
    "business:emergency-contact" = "vasyl.galiv@raiffeisen.ua"
    "MAPProjectId"               = "MPE32598"
    "entity"                     = "RBUA"
    "ea:shared-service"          = "false"
    "domain"                     = "PnP"
    "internet-faced"             = "false"

  }
}
