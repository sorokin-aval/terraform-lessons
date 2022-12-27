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
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.1.1"
  # source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  ebs_optimized = false
  vpc           = include.locals.account_vars.locals.vpc
  domain        = include.locals.account_vars.locals.domain
  name          = local.name
  ami           = "ami-031c2e21c7430b2a3"
  type          = "r5b.4xlarge"

  subnet  = "*-RestrictedA"
  zone    = "eu-central-1a"
  ssh-key = "dbre"

  iam_instance_profile = "ssm-ec2-role"

  security_groups = ["zabbix-agent", "Oracle DB", "commvault-agent"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-03o9qd47tfjh7z",
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
