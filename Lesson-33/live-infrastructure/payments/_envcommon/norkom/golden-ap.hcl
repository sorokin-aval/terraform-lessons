dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "smtp-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssh"),
    find_in_parent_folders("tg-alb"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  security_groups = ["ad", "ssh", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-020b2954batpyz" })
  # Security group rules
  ingress = [
    { from_port : 10101, to_port : 10101, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cda-deploy"], description : "cda-deploy" },
    { from_port : 15201, to_port : 15201, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cda-deploy"], description : "cda-deploy" },
    { from_port : 5044, to_port : 5044, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cda-deploy"], description : "cda-deploy" }
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mb"], description : "ibm-mb" },
    { from_port : 15201, to_port : 15201, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15701, to_port : 15701, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["lucky2"], description : "lucky2" }, # only test
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["yakus"], description : "yakus" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "ssh" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cda-deploy"], description : "ssh" },
  ]

  # Target group settings
  tg_entries = {
    "10101" = {
      target_port  = 10101
      target_group = dependency.tg-alb.outputs.target_groups["10101"].arn
    },
  }
}
