# Set list of tags that can be used in child configurations
locals {
  common_tags = {
    Owner                      = "Data"
    Confidentiality            = "0 - Non Business"
    Compliance                 = "None_playground"
    MAPProjectid               = "MPE32598"
    Provisioned                = "Terragrunt"
    PurchaseRequest            = "710379061"
    "security:environment"     = "Test"
    "security:confidentiality" = 0
    "business:cost-center"     = "0825"
    entity                     = "RBUA"
    domain                     = "Data"

  }
}
