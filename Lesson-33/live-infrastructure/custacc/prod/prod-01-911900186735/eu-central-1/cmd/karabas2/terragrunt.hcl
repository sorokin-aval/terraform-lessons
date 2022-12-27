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
  #  source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")

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
  ami    = "ami-08df26a76f3efdfa2"
  # 592760410760/karabas2_prod
  #  ami             = "ami-059745253304dcb5b"
  type = "t3.xlarge"

  ebs_optimized = true

  subnet  = "*-InternalB"
  zone    = "eu-central-1b"
  ssh-key = "platformOps"
  iam_instance_profile = "ssm-ec2-role"

  security_groups = ["zabbix-agent", "CMD-App"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-03t7qcw7449se4",
    Backup = "Daily-7day-Retention" }
  )


  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    #    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
    #    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
    #    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },


  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS SSM" },
  ]
}
