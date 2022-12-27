# Set list of tags that can be used in child configurations
locals {
  Environment  = "Test"
  Terraform    = "1.0.0"
  Owned        = "Terraform"
  BusinessUnit = "ITDeliveryTechnology"

  common_tags = {
    Owner                         = "Avalaunch"
    Confidentiality               = "0 - Non Business"
    Compliance                    = "None_playground"
    MAPProjectId                  = "MPE32598"
    Provisioned                   = "Terragrunt"
    BusinessUnit                  = "ITDeliveryTechnology"
    Project                       = "Avalaunch"
    PurchaseRequest               = "710373393"
    "security:environment"        = "Prod"
    "security:confidentiality"    = "0 - Non Business"
    "business:cost-center"        = "0789"
    "business:team"               = "Avalaunch"
    "business:product-project"    = "Avalaunch"
    "business:product-owner"      = "rodion.sabodash@raiffeisen.ua"
    "business:emergency-contact"  = "avalaunch_team@raiffeisen.ua"
    product                       = "AVALAUNCH"
    entity                        = "RBUA"
    domain                        = "Technology"
  }

}

