dependency "alb" { config_path = find_in_parent_folders("alb-internal/alb") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }
dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "sg-was-sake" { config_path = find_in_parent_folders("was-sake/sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("was-sake/sg"),
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
  ami_name        = "${local.name}"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  ebs_optimized   = false
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  # Security group rules
  ingress = [
    { from_port : 9443, to_port : 9443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9080, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9443, to_port : 9445, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9080, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 9080, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 9443, to_port : 9445, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg-was-sake.outputs.security_group_id], description : "was-sake-sg" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "stp-sg" },
    { from_port : 2800, to_port : 9999, protocol : "tcp", security_groups : [dependency.sg-was-sake.outputs.security_group_id], description : "was-sake-sg" },
    { from_port : 2800, to_port : 9999, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "stp-sg" },
    { from_port : 11005, to_port : 11005, protocol : "tcp", security_groups : [dependency.sg-was-sake.outputs.security_group_id], description : "was-sake-sg" },
    { from_port : 11005, to_port : 11099, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "stp-sg" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg-was-sake.outputs.security_group_id], description : "was-sake-sg" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "stp-sg" },
    { from_port : 2800, to_port : 9999, protocol : "tcp", security_groups : [dependency.sg-was-sake.outputs.security_group_id], description : "was-sake-sg" },
    { from_port : 2800, to_port : 9999, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "stp-sg" },
    { from_port : 11005, to_port : 11005, protocol : "tcp", security_groups : [dependency.sg-was-sake.outputs.security_group_id], description : "was-sake-sg" },
    { from_port : 11005, to_port : 11099, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "stp-sg" },
    { from_port : 15202, to_port : 15202, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15702, to_port : 15702, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 389, to_port : 389, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["tanker.noc-dc1"], description : "tanker.noc-dc1" },
    { from_port : 636, to_port : 636, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["tanker.noc-dc1"], description : "tanker.noc-dc1" },
    { from_port : 427, to_port : 427, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["tanker.noc-dc1"], description : "tanker.noc-dc1" },
    { from_port : 524, to_port : 524, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["tanker.noc-dc1"], description : "tanker.noc-dc1" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ose12x"], description : "ose12x" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 389, to_port : 389, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["novell"], description : "novell" },
  ]

  # Target group settings
  tg_entries = {
    "9443" = {
      target_port  = 9443
      target_group = dependency.tg-alb.outputs.target_groups["9443"].arn
    },
  }
}
