dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "smtp-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint")
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

skip = try(local.account_vars.locals.ec2_types[local.name], "") == "" ? true : false

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  security_groups = ["ad", "rdp", dependency.sg.outputs.security_group_name, "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-00he3236wirj7b" })
  # Security group rules
  ingress = [
    { from_port : 4899, to_port : 4899, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-internal"], description : "rbua-cbs-internal" },
    { from_port : 7006, to_port : 7006, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 7006, to_port : 7006, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 8021, to_port : 8022, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-vienna"], description : "mft-vienna" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-vienna"], description : "mft-vienna" },
    { from_port : 8085, to_port : 8085, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-vienna"], description : "mft-vienna" },
    { from_port : 50000, to_port : 65000, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-vienna"], description : "mft-vienna" },
    # only prod
    { from_port : 8021, to_port : 8022, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-kyiv"], description : "mft-kyiv" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-kyiv"], description : "mft-kyiv" },
    { from_port : 8085, to_port : 8085, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-kyiv"], description : "mft-kyiv" },
    { from_port : 50000, to_port : 65000, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mft-kyiv"], description : "mft-kyiv" },
    { from_port : 7005, to_port : 7005, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 7005, to_port : 7005, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
  ]
  # Target group settings
  tg_entries = {}
}
