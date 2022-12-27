dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "ap01" {
  config_path = find_in_parent_folders("was-ap01.${local.app_vars.locals.name}")
}

dependency "ap02" {
  config_path = find_in_parent_folders("was-ap02.${local.app_vars.locals.name}")
}

dependency "was-sake" {
  config_path = find_in_parent_folders("was-sake/ap01.was-sake")
}

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
  subnet          = "LZ-RBUA_Payments_*-RestrictedB"
  zone            = "eu-central-1b"
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "ssh", "observable", "${dependency.sg.outputs.security_group_name}"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01wfdcn2jk11g1" })
  # Security group rules
  ingress = [
    { from_port : 1521, to_port : 1526, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : ["${dependency.ap01.outputs.ec2_private_ip}/32"], description : dependency.ap01.outputs.name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.ap01.outputs.ec2_private_ip}/32"], description : dependency.ap01.outputs.name },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : ["${dependency.ap02.outputs.ec2_private_ip}/32"], description : dependency.ap02.outputs.name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.ap02.outputs.ec2_private_ip}/32"], description : dependency.ap02.outputs.name },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : ["${dependency.was-sake.outputs.ec2_private_ip}/32"], description : dependency.was-sake.outputs.name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.was-sake.outputs.ec2_private_ip}/32"], description : dependency.was-sake.outputs.name },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "DBRE VDI pool" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "DBRE VDI pool" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "HO-POOL-PAYMENTS" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "HO-POOL-PAYMENTS" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight"], description : "ArcSight" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight"], description : "ArcSight" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "commvault" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["test-app-pw"], description : "test-app-pw" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card-aws"], description : "ho-pool-card-aws" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-broker"], description : "ho-pool-broker" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-stp"], description : "oracle-db-stp" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rbua-vdi-it"], description : "rbua-vdi-it" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["data-internal-b"], description : "data-internal-b" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ns"], description : "ho-pool-ns" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "commvault" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-stp"], description : "oracle-db-stp" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-stp"], description : "oracle-db-stp" },

  ]
  # Target group settings
  tg_entries = {}
}
