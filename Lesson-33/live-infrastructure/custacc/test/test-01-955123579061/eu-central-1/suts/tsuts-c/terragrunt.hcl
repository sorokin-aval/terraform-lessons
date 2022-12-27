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
  ami    = "ami-04b58df3d9b51e528"
  type   = "t3a.medium"

  ebs_optimized        = false
  subnet               = "*-InternalB"
  zone                 = "eu-central-1b"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"

  #  security_groups = ["zabbix-agent"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated         = "d-server-028imaksj9m20c",
    "Maintenance Window" = "sun2",
    "Patch Group"        = "WinServers",
    "asm-patch"          = "yes",
    Backup               = "Daily-3day-Retention"
    }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS2SSM OUT" },
  ]
}
