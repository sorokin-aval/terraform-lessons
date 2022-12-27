dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
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
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  security_groups = ["ad", "ssh", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-0015v93oeagtrs" })
  # Security group rules
  ingress = [
    { from_port : 8443, to_port : 8443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zabbix"], description : "zabbix" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 15203, to_port : 15203, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15703, to_port : 15703, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    # only prod
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
  ]

  # Target group settings
  tg_entries = {
    "8443" = {
      target_port  = 8443
      target_group = dependency.tg-alb.outputs.target_groups["8443"].arn
    },
  }
}
