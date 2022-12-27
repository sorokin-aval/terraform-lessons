dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

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
  security_groups = ["ad", "rdp", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-025vwwdgi6hhrh" })
  # Security group rules
  ingress = [
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 2638, to_port : 2639, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["robin"], description : "robin" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cisaod"], description : "cisaod" },
    { from_port : 8081, to_port : 8081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mars"], description : "mars" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile01"], description : "uadho-wfile01" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile01"], description : "uadho-wfile01" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile01"], description : "uadho-wfile01" },
    { from_port : 15203, to_port : 15203, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "db.tm.payments.rbua" },
    { from_port : 15703, to_port : 15703, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "db.tm.payments.rbua" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "transit-db.tm.payments.rbua" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "transit-db.tm.payments.rbua" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-transfer"], description : "cbs-prod-01-transfer" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-restricted"], description : "cbs-prod-01-restricted" },
  ]
  # Target group settings
  tg_entries = {}
}
