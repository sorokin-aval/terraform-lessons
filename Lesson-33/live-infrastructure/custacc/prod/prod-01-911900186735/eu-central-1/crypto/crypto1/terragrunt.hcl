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
  #  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc    = include.locals.account_vars.locals.vpc
  domain = include.locals.account_vars.locals.domain
  name   = local.name
  #old ami  ami-07292f549464afc1b (uadLV-wSafe.ms.aval )
  # old  ami             = "ami-0e9989b37c401f959"
  ami  = "ami-01d2f0c23d9df4985"
  type = "t3a.medium"

  #  subnet          = "LZ-RBUA_Payments_*-InternalA"
  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"
  ebs_optimized        = false

  security_groups = ["zabbix-agent"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated         = "d-server-0211oobssvl731",
    "Maintenance Window" = "manual",
    "Patch Group"        = "WinServers",
    #    "asm-patch"          = "yes"
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS OUT" },
  ]
}

# pr
#
# prev  AMI ID = ami-0185f08fa170039bd
# prev snaps  snap-015adef5a5492f878   snap-0b0801b05cd7e1107