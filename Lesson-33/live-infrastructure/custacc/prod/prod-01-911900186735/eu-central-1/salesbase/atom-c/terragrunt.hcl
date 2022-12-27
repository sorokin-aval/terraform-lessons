# IT Customers and Account Services Delivery
include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  source = include.locals.account_vars.locals.sources["atom-c"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc    = include.locals.account_vars.locals.vpc
  domain = include.locals.account_vars.locals.domain
  name   = local.name
  ami    = "ami-018fb74f6d2005ebc"
  type   = "c4.2xlarge"
  subnet = "*-InternalA"
  zone   = "eu-central-1a"
  tags = merge(local.app_vars.locals.tags, {
    application_role = "HO-BAPP-SALES-BASE",
    map-migrated     = "d-server-029p4vwnjv70w1",
  Backup = "Daily-7day-Retention" })
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "SSH" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTP" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS" },
    { from_port : 3690, to_port : 3690, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SVN" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["0.0.0.0/0"], description : "ALL OUT" },
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "" },
  ]
}
