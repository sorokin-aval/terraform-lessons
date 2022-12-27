locals {
    tags = {
        "entity"                     = "RBUA"
        "domain"                     = "Payments"
        "MAPProjectid"               = "MPE32598"
        "business:team"              = "Payments SRE"
        "business:product-owner"     = "it.payments@raiffeisen.ua"
        "business:emergency-contact" = "it.payments@raiffeisen.ua"
        "ea:shared-service"          = "false"
        "security:confidentiality"   = "3 - Confidential"
        "provisioned"                = "Terragrunt"
    }
    common_tags = {
        "business:product-project" = "Payments-shared"
        "product"                  = "Payments-shared"
    }
}
