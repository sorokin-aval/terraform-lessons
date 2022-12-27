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
  #source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
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
  #  name            = "uadKH-wSafe1" 
  # old ami-0c856f4e29e139047 (uadKH-wSafe.ms.aval )
  ami  = "ami-050c8a2d92b29f725"
  type = "t3a.medium"
  #  private_ip      = "10.226.138.246"
  block_device_encrypted = false
  ebs_optimized          = false

  subnet               = "*-InternalB"
  zone                 = "eu-central-1b"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"


  security_groups = ["zabbix-agent", "safes"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-03pq5p0qreokfr",
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
