# Set list of tags that can be used in child configurations
locals {
  System           = "RBO"
  owner            = "Channels"
  env              = "preprod"
  compliance       = "None_playground"
  confidentiality  = "2"
  Provisioned      = "Terragrunt"
  MAPProjectid     = "MPE32598"
  application_role = local.System
  product          = local.System # "CName from https://jira.raiffeisen.ua/jira/secure/ObjectSchema.jspa?id=110&typeId=452&view=list&objectId=147197"
}
