locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  tags_map     = local.account_vars.locals.tags
  name         = "${local.app_vars.locals.name}-${local.account_vars.locals.aws_account_id}"
}

terraform {
  source = local.account_vars.locals.sources["statements"]
}

inputs = {

  prefix_name = "statements"
  clients     = ["GUALAPAK", "BOEHRINGER", "LIKTRAVY", "JUSK", "TAKEDA", "GORENJE", "REDBULL", "SOUFFLET", "METRO", "VIESMANN", "INTERTOP", "BEIERSDORF", "PHILIPMORRIS", "SWTEST"]
  allow_ips   = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22", "134.249.52.205/32"]

  tags = local.app_vars.locals.tags
}
