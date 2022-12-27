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
  # old ami ami-038238598f5a18c92 (freeze.app.kv.aval)
  ami = "ami-042cbcecb2855daf0"
  #  type            = "t3a.xlarge"
  type = "t3.2xlarge"
  #  private_ip      = "10.226.138.194"

  #  subnet          = "LZ-RBUA_Payments_*-InternalA"
  subnet  = "*-InternalA"
  zone    = "eu-central-1a"
  ssh-key = "platformOps"
  #  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  #  security_groups = ["${dependency.sg.outputs.security_group_name}"]
  #   lifecycle { ignore_changes = [ebs_block_device] }
  iam_instance_profile = "ssm-ec2-role"

  security_groups = ["zabbix-agent", "medoc", "ms-share"]
  #  security_groups = ["zabbix-agent"]
  #  tags            = merge(local.common_tags.locals, { application_role = local.app_vars.locals.name, map-migrated = "d-server-02ou594b5lcpe5" })
  #  tags            = merge(local.common_tags.locals, {
  tags = merge(local.app_vars.locals.tags, {
    map-migrated         = "d-server-03jmlbac469eev",
    "Maintenance Window" = "sun3",
    "Patch Group"        = "WinServers",
    "asm-patch"          = "stop11.22",
    Backup = "Daily-3day-Retention" }
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
    { from_port : 9996, to_port : 9996, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "MEDOC" },
    { from_port : 9080, to_port : 9080, protocol : "tcp", cidr_blocks : ["10.191.4.103/32"], description : "dinosaur" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
