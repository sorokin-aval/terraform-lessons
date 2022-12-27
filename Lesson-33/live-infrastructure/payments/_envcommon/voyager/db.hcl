dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "cv-ma01" { config_path = find_in_parent_folders("core-infrastructure/comm-vault/cv-ma01") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/rdp"),
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
  security_groups = ["ad", "rdp", "observable", "${dependency.sg.outputs.security_group_name}"]
  ebs_optimized   = true
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-02gx2y7f9cjc7s" })
  # Security group rules
  ingress = [
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 1434, to_port : 1434, protocol : "udp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 1438, to_port : 1438, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 5025, to_port : 5025, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 138, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 1434, to_port : 1434, protocol : "udp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 1440, to_port : 1440, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 5023, to_port : 5023, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    # only prod
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
  ]
  egress = [
    { from_port : 53, to_port : 53, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ad"], description : "ad DNS UDP" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 1434, to_port : 1434, protocol : "udp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 1438, to_port : 1438, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 1440, to_port : 1440, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 5022, to_port : 5023, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 5025, to_port : 5025, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"], description : "imperator" },
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 8400, to_port : 8400, protocol : "tcp", security_groups: [dependency.cv-ma01.outputs.security_group_id], description : dependency.cv-ma01.outputs.name },
    { from_port : 8403, to_port : 8403, protocol : "tcp", security_groups : [dependency.cv-ma01.outputs.security_group_id], description : dependency.cv-ma01.outputs.name },
  ]
  # Target group settings
  tg_entries = {}
}
