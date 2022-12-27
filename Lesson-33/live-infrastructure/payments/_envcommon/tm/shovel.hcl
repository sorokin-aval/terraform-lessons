dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

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
  ami_name        = "shovel-ap01-tm"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  security_groups = ["ad", "rdp", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-02810oejpsq08t" })
  # Security group rules
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["b-tm.todb"], description : "b-tm.todb" },
    { from_port : 2651, to_port : 2651, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["sheriff.tsdb"], description : "sheriff.tsdb" },
    { from_port : 15203, to_port : 15203, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "db.tm" },
    { from_port : 15703, to_port : 15703, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "db.tm" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "db-transit.tm" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    # only prod
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cisaod"], description : "cisaod" },
    { from_port : 2638, to_port : 2638, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["barracuda"], description : "barracuda" },
    { from_port : 2638, to_port : 2638, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["tuna"], description : "tuna" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 2638, to_port : 2638, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["sheriff2019.sdb"], description : "sheriff2019.sdb" },
    { from_port : 2638, to_port : 2638, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["sheriff-aws"], description : "sheriff-aws" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-transfer"], description : "rbua-cbs-transfer" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-restricted"], description : "rbua-cbs-restricted" },
  ]
  # Target group settings
  tg_entries = {}
}
