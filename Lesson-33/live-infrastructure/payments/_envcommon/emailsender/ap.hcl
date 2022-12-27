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
  account_vars           = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars               = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name                   = basename(get_terragrunt_dir())
  payments_0308_internal = local.account_vars.locals.environment == "test" ? "payments-test-03-internal" : "payments-prod-08-internal"
}

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.new_domain
  name            = local.name
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  security_groups = ["ad", "rdp", "${dependency.sg.outputs.security_group_name}", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-025vwwdgi6hhrh" })
  ebs_optimized   = false
  # Security group rules
  ingress = [
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.payments_0308_internal], description : "ap01.smtp.payments.rbua" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["awsec2-wfile01"], description : "awsec2-wfile01" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile01"], description : "uadho-wfile01" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile01"], description : "uadho-wfile01" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile01"], description : "uadho-wfile01" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-restricted"], description : "rbua-cbs-restricted" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-restricted"], description : "rbua-cbs-restricted" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibrahim.b2"], description : "ibrahim.b2" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibrahim.b2"], description : "ibrahim.b2" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-dev-01"], description : "cbs-dev-01" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-dev-01"], description : "cbs-dev-01" },
  ]
  # Target group settings
  tg_entries = {}
}
