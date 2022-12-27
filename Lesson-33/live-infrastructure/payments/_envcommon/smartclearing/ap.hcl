dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "smtp-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint") }
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
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-020zya2d8ytar8" })
  # Security group rules
  ingress = [
    { from_port : 9443, to_port : 9443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 9043, to_port : 9080, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9080, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9443, to_port : 9444, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9080, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9443, to_port : 9444, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9443, to_port : 9444, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "smartclearing-sg" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  egress = [
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "smartclearing-sg" },
    { from_port : 15201, to_port : 15201, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15701, to_port : 15701, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ms-share"], description : "ms-share" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ms-share"], description : "ms-share" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["lucky2"], description : "lucky2" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  # Target group settings
  tg_entries = {
    "9043" = {
      target_port  = 9043
      target_group = dependency.tg-alb.outputs.target_groups["9043"].arn
    },
    "9044" = {
      target_port  = 9044
      target_group = dependency.tg-alb.outputs.target_groups["9044"].arn
    },
    "9443" = {
      target_port  = 9443
      target_group = dependency.tg-alb.outputs.target_groups["9443"].arn
    },
    "9080" = {
      target_port  = 9080
      target_group = dependency.tg-alb.outputs.target_groups["9080"].arn
    },
  },
}
