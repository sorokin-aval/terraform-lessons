dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }
dependency "rds-trust" { config_path = find_in_parent_folders("rds-sg") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint"),
    find_in_parent_folders("core-infrastructure/vpc-info"),
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
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "" })
  # Security group rules
  ingress = [
    { from_port : 9443, to_port : 9443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 9080, to_port : 9080, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 9080, to_port : 9080, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cyberark-subnet"], description : "cyberark-subnet" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cyberark-subnet"], description : "cyberark-subnet" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet-cidr-blocks" },
    { from_port : 2800, to_port : 9999, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet-cidr-blocks" },
    { from_port : 11005, to_port : 11099, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet-cidr-blocks" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet-cidr-blocks" },
    { from_port : 2800, to_port : 9999, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet-cidr-blocks" },
    { from_port : 11005, to_port : 11099, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet-cidr-blocks" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", security_groups : [dependency.rds-trust.outputs.security_group_id], description : "rds-trust" },
    { from_port : 137, to_port : 139, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : dependency.sg.outputs.security_group_name }, 
    { from_port : 445, to_port : 445, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : dependency.sg.outputs.security_group_name }, 
  ]
  # Target group settings
  tg_entries = {
    "9443" = {
      target_port  = 9443
      target_group = dependency.tg-alb.outputs.target_groups["9443"].arn
    },
  }
}
