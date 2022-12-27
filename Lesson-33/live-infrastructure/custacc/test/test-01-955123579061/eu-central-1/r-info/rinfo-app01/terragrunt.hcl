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
  source = include.locals.account_vars.locals.sources["host"]
#  source = find_in_parent_folders("../../modules/host")

}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name        = basename(get_terragrunt_dir())
}

inputs = {
  vpc             = include.locals.account_vars.locals.vpc
  domain          = include.locals.account_vars.locals.domain
  name            = local.name
#sandbox
#  ami             = "ami-0ee2bc5c3d8c65ac0"
# our test
  ami             = "ami-077b0ad3320fb05c5"
  type            = "t3a.xlarge"

  subnet          = "*-InternalA"
  zone            = "eu-central-1a"
  ssh-key         = "platformOps"
  iam_instance_profile = "ssm-ec2-role"

  #  security_groups = ["zabbix-agent"]
  tags            = merge(local.app_vars.locals.tags, {
    application_role = "HO-BAPP-RINFO-TEST",
    map-migrated = "d-server-01l1t63213j1hx",
    Backup = "Weekly-4Week-Retention"}
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH-IN" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS2" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS3" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS2SSM OUT" },
  ]
}
