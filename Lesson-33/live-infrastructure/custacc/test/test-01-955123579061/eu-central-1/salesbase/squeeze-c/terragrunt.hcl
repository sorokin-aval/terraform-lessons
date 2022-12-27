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
#   source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  ebs_optimized = false
  vpc    = include.locals.account_vars.locals.vpc
  domain = include.locals.account_vars.locals.domain
  name   = local.name
  ami    = "ami-0bb5c8906d04cbaf6"
  type   = "t3a.medium"

  subnet = "*-InternalA"
  zone   = "eu-central-1a"
  #  ssh-key         = "platformOps"
  ssh-key = "custaccadmins"

  iam_instance_profile = "ssm-ec2-role"

  ###  security_groups = ["zabbix-agent", "safes"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated     = "d-server-00f3jhzyoimls8",
    Backup = "Daily-3day-Retention" }
  )

#  root_block_device = [
#    {
#      encrypted = false,
#      volume_size = "110",
#      volume_type = "gp3"
#    }
#  ]

  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTP" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS2" },
    #    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "RDP" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["0.0.0.0/0"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS2SSM OUT" },
  ]
}
