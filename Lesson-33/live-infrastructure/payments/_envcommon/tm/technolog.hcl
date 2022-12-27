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
  account_vars           = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars               = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name                   = basename(get_terragrunt_dir())
  payments_0308_internal = local.account_vars.locals.environment == "test" ? "payments-test-03-internal" : "payments-prod-08-internal"
}

skip = try(local.account_vars.locals.ec2_types[local.name], "") == "" ? true : false

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  security_groups = ["ad", "rdp", dependency.sg.outputs.security_group_name, "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01ncqwn7rckpgk" })
  # Security group rules
  ingress = [
    { from_port : 4899, to_port : 4899, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-internal"], description : "rbua-cbs-internal" },
    { from_port : 7006, to_port : 7006, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 7006, to_port : 7006, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-restricted"], description : "payments-prod-09-restricted" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-restricted"], description : "payments-prod-09-restricted" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 15202, to_port : 15203, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15702, to_port : 15703, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.payments_0308_internal], description : "ap01.smtp.payments.rbua" },
    # only prod
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["tmaster"], description : "tmaster" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["iscard"], description : "iscard" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["iscard"], description : "iscard" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["aws-wfile"], description : "aws-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 7005, to_port : 7005, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 7005, to_port : 7005, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["door"], description : "door" },
    { from_port : 2640, to_port : 2640, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["iq.sdb"], description : "iq.sdb" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rightrock-vip.odb"], description : "rightrock-vip.odb" },
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 15203, to_port : 15203, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-transfer"], description : "payments-prod-09-transfer" },
    { from_port : 15703, to_port : 15703, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-transfer"], description : "payments-prod-09-transfer" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
  ]
  # Target group settings
  tg_entries = {}
}
