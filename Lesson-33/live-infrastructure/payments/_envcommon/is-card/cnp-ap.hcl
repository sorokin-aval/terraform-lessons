dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "smtp-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb" { config_path = find_in_parent_folders("alb-internal/alb") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssh"),
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
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-03ju7pxgzeke53" })
  ebs_optimized   = false
  # Security group rules
  ingress = [
    { from_port : 8443, to_port : 8447, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 8443, to_port : 8447, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card-aws"], description : "ho-pool-card-aws" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 9041, to_port : 9041, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["pos-gateway"], description : "POS Gateway" },
    { from_port : 15202, to_port : 15202, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15702, to_port : 15702, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 12396, to_port : 12396, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ps-hsm"], description : "ps-hsm" },
    { from_port : 9094, to_port : 9094, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kafka"], description : "kafka" },
    # only prod
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["iscard"], description : "iscard" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["iscard"], description : "iscard" },
    { from_port : 8443, to_port : 8447, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
  ]

  # Target group settings
  tg_entries = {
    "isc-8443" = {
      target_port  = 8443
      target_group = dependency.tg-alb.outputs.target_groups["isc-8443"].arn
    },
    "isc-8445" = {
      target_port  = 8445
      target_group = dependency.tg-alb.outputs.target_groups["isc-8445"].arn
    },
    "isc-8447" = {
      target_port  = 8447
      target_group = dependency.tg-alb.outputs.target_groups["isc-8447"].arn
    },
  }
}
