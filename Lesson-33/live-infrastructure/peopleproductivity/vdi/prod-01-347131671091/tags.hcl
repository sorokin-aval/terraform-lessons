# Set list of tags that can be used in child configurations
locals {
    
  Environment     = "prod"
  Owner           = "PeopleProductivity"
  Confidentiality = "3"
  Compliance      = "None_playground"
  MAPProjectid    = "MPE32598"
  Provisioned     = "Terragrunt"
  BusinessUnit    = "PeopleProductivity"
  Project         = "appstream"
  PurchaseRequest = "710381585"
####
#   security:environment       = "Prod"
#   business:product-project   = "appstream"
#   map-migrated               = "null"
#   map-dba                    = "null"
#   product                    = "VDI"
#   ea:application-id          = "null"
#   ea:application-name        = "null"
# ####
#   security:confidentiality   = "3"
#   business:cost-center       = "520"
#   business:team              = "Infrastructure team"
#   business:product-owner     = "andrii.kovtun@raiffeisen.ua"
#   business:emergency-contact = "vasyl.galiv@raiffeisen.ua"
#   MAPProjectId               = "MPE32598"
#   entity                     = "RBUA"
#   ea:shared-service          = "false"
#   domain                     = "PnP"
#   internet-faced             = "false"

}

