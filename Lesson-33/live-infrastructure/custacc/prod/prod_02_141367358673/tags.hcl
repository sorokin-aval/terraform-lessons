locals {
  owner           = lower(basename(dirname(dirname(get_terragrunt_dir()))))
  env             = basename(dirname(get_terragrunt_dir()))
  aws_account_id  = regex("[0-9]+$", basename(get_terragrunt_dir()))
  MAPProjectid    = "MPE32598"
  compliance      = "None_playground"
  confidentiality = "3"
  provisioned     = "Terragrunt"
  BusinessUnit    = "IT Delivery Customers and Account Services Division"
  PurchaseRequest = "710382033"
}