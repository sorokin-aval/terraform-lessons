# Set list of tags that can be used in child configurations
locals {
  common_tags = {
    Owner                        = "D.Raif"
    Confidentiality              = "0 - Non Business"
    Compliance                   = "None_playground"
    MAPProjectId                 = "MPE32598"
    Provisioned                  = "Terragrunt"
    BusinessUnit                 = "D.Raif"
    PurchaseRequest              = "710380305"
    "security:environment"       = "Dev"
    "security:confidentiality"   = "0 - Non Business"
    "business:cost-center"       = "0825"
    "business:emergency-contact" = "it.dataops@raiffeisen.ua"
    entity                       = "RBUA"
    domain                       = "Data"
  }
}
