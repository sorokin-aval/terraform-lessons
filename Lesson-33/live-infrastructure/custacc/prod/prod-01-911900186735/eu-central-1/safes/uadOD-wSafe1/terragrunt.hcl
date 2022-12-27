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
  #old ami ami-00acd79647fbaea1f (uadOD-wSafe.ms.aval )
  ami           = "ami-04ecf2b91aa3bba03"
  type          = "t3a.medium"
  ec_private_ip = "10.226.138.196"

  block_device_encrypted = false
  ebs_optimized          = false

  subnet               = "*-InternalB"
  zone                 = "eu-central-1b"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"


  security_groups = ["zabbix-agent", "safes"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-01ydy5nb6f83tu",
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
