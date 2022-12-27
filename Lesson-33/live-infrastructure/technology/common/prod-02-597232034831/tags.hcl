## Set list of tags that can be used in child configurations
locals {
  Environment     = "Prod"
  Owner           = "Avalaunch"
  Confidentiality = "3"
  MAPProjectid    = "MPE32598"
  Provisioned     = "Terragrunt"
  BusinessUnit    = "Technology"
  Project         = "Avalaunch"

  common_tags = {
    "security:environment"     = "Prod"
    "security:confidentiality" = "3 - Confidential"
    "business:product-owner"   = "rodion.sabodash@raiffeisen.ua"
    "MAPProjectId"             = "MPE32598"
    "entity"                   = "RBUA"
    "ea:shared-service"        = "true"
    "domain"                   = "Technology"
    "internet-faced"           = "false"
  }
}