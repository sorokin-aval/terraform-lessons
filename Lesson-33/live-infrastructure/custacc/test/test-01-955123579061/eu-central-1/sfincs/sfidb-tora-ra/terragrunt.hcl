# IT Customers and Account Services Delivery
include {
  path   = find_in_parent_folders()
  expose = true
}

iam_role = local.account_vars.iam_role


dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}


terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.1.1"
  #  source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
  #  source = include.locals.account_vars.locals.sources["host"]
  #  source = find_in_parent_folders("../../modules/host")

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
  # !!! new ami from Lechenko [PLSUPP-31235] Test env SFIDB configuration
  #  ami = "ami-0e0771e52351defa4"
  #  old ami from prod instance
  ami  = "ami-0d317de2a742e09d4"
  type = "r5.large"
  #  type            = "t3a.xlarge"

  subnet               = "*-RestrictedA"
  zone                 = "eu-central-1a"
  ssh-key              = "dbre"
  iam_instance_profile = "ssm-ec2-role"

  #  security_groups = ["zabbix-agent", "Oracle DB","commvault-agent"]
  security_groups = ["oracle"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-015ygzq6nvnai1",
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
