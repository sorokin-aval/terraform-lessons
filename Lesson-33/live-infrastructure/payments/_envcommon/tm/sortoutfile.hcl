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
  ami_name        = "${local.name}-v0.01"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  security_groups = ["ad", "rdp", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-025vwwdgi6hhrh" })
  # Security group rules
  ingress = [
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 15202, to_port : 15203, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15702, to_port : 15703, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mb"], description : "ibm-mb" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    # only prod
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["yakus"], description : "yakus" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["door"], description : "door" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["iscard"], description : "iscard" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["iscard"], description : "iscard" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
  ]
  # Target group settings
  tg_entries = {}
}
