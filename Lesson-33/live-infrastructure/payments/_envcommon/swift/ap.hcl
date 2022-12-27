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
  ebs_optimized   = false
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  # Security group rules
  ingress = [
    { from_port : 1414, to_port : 1421, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "swift-sg" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 1414, to_port : 1421, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "swift-sg" },
    { from_port : 1364, to_port : 1364, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["connect-direct-crisp"], description : "connect-direct-crisp" },
    { from_port : 1364, to_port : 1364, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["connect-direct-rbi"], description : "connect-direct-rbi" },
    { from_port : 1414, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mq-rbi"], description : "ibm-mq-rbi" },
    { from_port : 1414, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mq-crisp"], description : "ibm-mq-crisp" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mgwt-crisp"], description : "mgwt-crisp" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  # Target group settings
  tg_entries = {}
}
