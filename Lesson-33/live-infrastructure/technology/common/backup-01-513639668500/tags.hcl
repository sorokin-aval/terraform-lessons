# Set list of tags that can be used in child configurations

locals {
  tags = {
    "security:environment"       = "Prod"
    "security:confidentiality"   = "3 - Confidential"
    "business:cost-center"       = "465"
    "business:team"              = "Technology"
    "business:product-project"   = "BACKUP"
    "business:product-owner"     = "rodion.sabodash@raiffeisen.ua"
    "business:emergency-contact" = "oleksandr.lytvyniuk@raiffeisen.ua"
#    "map-migrated"               = "d-server-00sj1xhbfx35r4"
    "MAPProjectId"               = "MPE32598"
    "product"                    = "BACKUP"
    "entity"                     = "RBUA"
    "ea:shared-service"          = "true"
    "ea:application-id"          = "22804"
    "ea:application-name"        = "HDPS_Commvault"
    "domain"                     = "Technology"
    "internet-faced"             = "false"
  }
}
