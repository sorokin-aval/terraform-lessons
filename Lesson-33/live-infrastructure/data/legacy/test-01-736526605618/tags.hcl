# Set list of tags that can be used in child configurations
locals {
  common_tags = {
    Owner                        = "Data"
    MAPProjectId                 = "MPE32598"
    Provisioned                  = "Terragrunt"
    BusinessUnit                 = "D.Raif"
    "security:environment"       = "Test"
    "security:confidentiality"   = "3 - Confidential"
    "business:cost-center"       = "0825"
    "business:team"              = "D.Raif"
    "business:product-owner"     = "artem.ternov@raiffeisen.ua"
    "business:emergency-contact" = "it.dataops@raiffeisen.ua"
    product                      = "legacy"
    entity                       = "RBUA"
    internet-faced               = false
    domain                       = "Data"
  }
}

