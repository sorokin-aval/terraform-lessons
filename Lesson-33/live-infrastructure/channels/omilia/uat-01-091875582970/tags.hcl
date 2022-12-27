# Set list of tags that can be used in child configurations
locals {
  System           = "Omilia"
  owner            = "Channels"
  env              = "uat"
  compliance       = "None_playground"
  confidentiality  = "2"
  Provisioned      = "Terragrunt"
  MAPProjectid     = "MPE32598"
  application_role = local.System
}
