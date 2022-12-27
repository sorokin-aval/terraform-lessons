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
  # source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
  #  source = include.locals.account_vars.locals.sources["host"]
  #  source = find_in_parent_folders("../../modules/host")

}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc           = include.locals.account_vars.locals.vpc
  domain        = include.locals.account_vars.locals.domain
  name          = local.name
  name          = local.name
  ami           = "ami-0dc2bfcbd53f2bcd6" #ORACLE_DB_CMD_4LAZUTIN_TEST
  type          = "t3a.large"
  ebs_optimized = false
  subnet        = "*-RestrictedA"
  zone          = "eu-central-1a"
  #  ssh-key         = "dbre"
  ssh-key = "platformOps"

  iam_instance_profile = "ssm-ec2-role"

  #  security_groups = ["zabbix-agent", "Oracle DB"]

  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-01qk53073ldk8w",
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : ["10.191.2.184/32", "10.226.138.30/32"], description : "bigpoint.ms.aval comvault" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
