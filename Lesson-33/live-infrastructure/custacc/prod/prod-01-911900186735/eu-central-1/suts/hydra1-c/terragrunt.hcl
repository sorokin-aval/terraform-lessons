# IT Customers and Account Services Delivery
include {
  path   = find_in_parent_folders()
  expose = true
}

#dependency "sg" {
#  config_path = find_in_parent_folders("sg")
#}

#dependency "ssm-vpc-endpoint" {
#  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
#}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.1.1"
  # source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
  #  source = include.locals.account_vars.locals.sources["host"]
  #  source = find_in_parent_folders("../../modules/host")

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
  #old ami ami-0c1a5c62668b72dc0 (hydra1.app.kv.aval_31.08)
  ami  = "ami-010c200780d072893"
  type = "t3a.medium"

  subnet  = "*-InternalA"
  zone    = "eu-central-1a"
  ssh-key = "platformOps"
  #  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  #  security_groups = ["${dependency.sg.outputs.security_group_name}"]
  #   lifecycle { ignore_changes = [ebs_block_device] }
  iam_instance_profile = "ssm-ec2-role"


  #  security_groups = ["zabbix-agent"]
  #  tags            = merge(local.common_tags.locals, { application_role = local.app_vars.locals.name, map-migrated = "d-server-02ou594b5lcpe5" })
  #  tags            = merge(local.common_tags.locals, {
  tags = merge(local.app_vars.locals.tags, {
    #    application_role = "NIFI",
    #    application_role = local.app_vars.locals.name,
    map-migrated         = "d-server-00qfnu05q0ytsh",
    "Maintenance Window" = "sun4",
    "Patch Group"        = "WinServers",
    "asm-patch"          = "stop11.22",
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
