# Set list of tags that can be used in child configurations
locals {
  Environment     = "Dev"
  Owned           = "Terraform"
  BusinessUnit    = "ITDeliveryTechnology"
  PurchaseRequest = "710375553"
  Project         = "Avalaunch"
  MAPProjectid    = "MPE32598"
  env             = "dev"
  confidentiality = "2"
  compliance      = "None_playground"
  owner           = "Technology"
  application_role= "Kubernetes"


  common_tags = {
    Owner                         = "Avalaunch"
    Confidentiality               = "0 - Non Business"
    Compliance                    = "None_playground"
    MAPProjectId                  = "MPE32598"
    Provisioned                   = "Terragrunt"
    BusinessUnit                  = "ITDeliveryTechnology"
    Project                       = "Avalaunch"
    PurchaseRequest               = "710373393"
    "security:environment"        = "Dev"
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
