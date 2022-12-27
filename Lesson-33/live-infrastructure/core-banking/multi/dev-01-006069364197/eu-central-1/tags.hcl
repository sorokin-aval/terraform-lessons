locals {
  # https://jira.raiffeisen.ua/wiki/pages/viewpage.action?pageId=187924491
  owner    = "CBS"
  env      = "dev"
  compliance = "None_playground"
  confidentiality = "0"
  Provisioned = "Terragrunt"
  MAPProjectid = "MPE32598"

  application_role = "-"

  # in case of non-RDS instance type
  map-migrated = "-"

  # in case of RDS instance type
  map-dba = "-"

}
