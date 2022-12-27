#  Set list of tags that can be used in child configurations
locals {
  common_tags = {
    Owner                        = "Data"
    MAPProjectId                 = "MPE32598"
    Provisioned                  = "Terragrunt"
    BusinessUnit                 = "D.Raif"
    PurchaseRequest              = "170818799699"
    "security:environment"       = "Prod"
    "security:confidentiality"   = "3 - Confidential"
    "business:cost-center"       = "0658"
    "business:team"              = "Gdwh-team"
    "business:product-owner"     = "mykola.pavlyk@raiffeisen.ua"
    "business:emergency-contact" = "it.dataops@raiffeisen.ua"
    product                      = "GDWH"
    entity                       = "RBUA"
    internet-faced               = false
    domain                       = "Data"
  }
}
