#  Custacc
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
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  ebs_optimized        = false
  vpc                  = include.locals.account_vars.locals.vpc
  domain               = include.locals.account_vars.locals.domain
  name                 = local.name
  ami                  = "ami-0a1ee2fb28fe05df3"
  type                 = "t3a.micro"
  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  iam_instance_profile = "ssm-ec2-role"
  tags = merge(local.app_vars.locals.tags, {
    application_role = "SMTP Relay server",
    map-migrated     = "d-server-00a6j7i251f7mu"
  })
  ingress = [
    #    { from_port : 8443, to_port : 8447, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    #    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "SSH" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : ["10.226.138.58/32"], description : "EMAIL25test" },
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : ["10.226.138.5/32"], description : "EMAIL25atom-c" },
    #    { from_port : 587, to_port : 587, protocol : "tcp", cidr_blocks : ["10.226.138.0/23"], description : "EMAIL587" },
    #    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "oracle" },
    #    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS" },
  ]
  egress = [
    #    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    #    { from_port : 9041, to_port : 9041, protocol : "tcp", cidr_blocks : include.locals.account_vars.locals.ips["pos-gateway"], description : "POS Gateway" },
    #    { from_port : 15202, to_port : 15202, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    #    { from_port : 15702, to_port : 15702, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    #    { from_port : 12396, to_port : 12396, protocol : "tcp", cidr_blocks : include.locals.account_vars.locals.ips["ps-hsm"], description : "ps-hsm" },
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["0.0.0.0/0"], description : "ALL OUT" },
  ]
}
