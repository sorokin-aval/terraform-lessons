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
  #  source = include.locals.account_vars.locals.sources["host"]
  #  source = find_in_parent_folders("../../modules/host")

}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  ebs_optimized          = false
  block_device_encrypted = false

  vpc    = include.locals.account_vars.locals.vpc
  domain = include.locals.account_vars.locals.domain
  name   = local.name
  #old ami ami-03f2cf3dc3aaef960 (uadDP-wSafe.ms.aval)
  ami  = "ami-03976506c524090fa"
  type = "t3a.medium"

  #  subnet          = "LZ-RBUA_Payments_*-InternalA"
  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"


  security_groups = ["zabbix-agent", "safes"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-03o9qd47tfjh7z",
    Backup = "Daily-3day-Retention" }
  )


  root_block_device = [
    {
      volume_size = "60"
      volume_type = "gp3"
    }
  ]


  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
