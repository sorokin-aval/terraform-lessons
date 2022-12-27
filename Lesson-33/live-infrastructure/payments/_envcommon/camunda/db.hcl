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
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "" })

  # Security group rules
  ingress = [
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["psgq-on-premise"], description : "psgq-on-premise" },
    { from_port : 8008, to_port : 8008, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["psgq-on-premise"], description : "psgq-on-premise" },
    { from_port : 2379, to_port : 2379, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["psgq-on-premise"], description : "psgq-on-premise" },
  ]
  egress  = [
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "External packages" },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["psgq-on-premise"], description : "psgq-on-premise" },
    { from_port : 8008, to_port : 8008, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["psgq-on-premise"], description : "psgq-on-premise" },
    { from_port : 2379, to_port : 2379, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["psgq-on-premise"], description : "psgq-on-premise" },
  ]
  # Target group settings
  tg_entries = {}
}
