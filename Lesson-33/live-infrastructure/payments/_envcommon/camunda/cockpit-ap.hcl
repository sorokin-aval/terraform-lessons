dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars          = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name              = basename(get_terragrunt_dir())
  avalaunch-account = local.account_vars.locals.environment == "test" ? "avalaunch-dev-mzwc-internal" : "avalaunch-dev-mig-2k3h-internal"
}

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = "${local.name}"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = local.app_vars.locals.tags
  # Security group rules
  ingress = [
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 7845, to_port : 7845, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 7850, to_port : 7850, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["was2jb"], description : "was2jb" },
    { from_port : 9094, to_port : 9094, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kafka"], description : "kafka" },
  ]
  # Target group settings
  tg_entries = {}
}
