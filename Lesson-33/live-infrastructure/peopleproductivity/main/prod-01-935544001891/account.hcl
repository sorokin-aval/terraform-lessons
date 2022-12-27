# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "RBUA_AD_SHARED_PROD_01"
  aws_account_id = "935544001891"
  environment    = "prod"

  tags = {
    ###
    "security:environment"       = "Prod"
    "business:product-project"   = ""
    "map-migrated"               = ""
    "map-dba"                    = ""
    "product"                    = ""
    "ea:application-id"          = "0"
    "ea:application-name"        = "NA"
    "PurchaseRequest"            = "710381585"
    ####
    # Backup plans:
    # Daily-7day-Retention/Daily-14day-Retention/Daily-3day-Retention/Daily-7day-Retention/Weekly-4Week-Retention/Monthly-2Month-Retention
    # "platform:backup" = "Daily-14day-Retention"
    ####
    "security:confidentiality"   = "3 - Confidential"
    "business:cost-center"       = "520"
    "business:team"              = "Infrastructure team"
    "business:product-owner"     = "andrii.kovtun@raiffeisen.ua"
    "business:emergency-contact" = "vasyl.galiv@raiffeisen.ua"
    "MAPProjectId"               = "MPE32598"
    "entity"                     = "RBUA"
    "ea:shared-service"          = "false"
    "domain"                     = "PnP"
    "internet-faced"             = "false"
    "Provisioned"                = "Terragrunt"
  }
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
