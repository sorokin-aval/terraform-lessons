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
  #  source = include.locals.account_vars.locals.sources["ua-tf-aws-payments-host"]
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
  # from web-cmd01  682969052504\ami-06ba80c3701bea995 (cmdt.test.kv.aval)
  #  ami             = "ami-06cec0aa1cdd58693"
  ami  = "ami-064896c5f9fee269c"
  type = "t3a.medium"
  #  type            = "t3a.large"
  ebs_optimized        = true
  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"

  security_groups = ["Zabbix-Agent", "CMD-App"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-00ix369jwn620g",
    Backup = "Daily-7day-Retention" }
  )


  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS OUT" },
  ]
}
