# Set list of tags that can be used in child configurations
locals {
  System           = "Sandbox"
  owner            = "Channels"
  env              = "test"
  compliance       = "None_playground"
  confidentiality  = "2"
  Provisioned      = "Terragrunt"
  MAPProjectid     = "MPE32598"
  application_role = local.System
}
