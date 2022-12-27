dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "rds-trust" { config_path = find_in_parent_folders("rds-sg") }

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
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "rdp", "${dependency.sg.outputs.security_group_name}", "observable"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-039endumtyqr69" })
  # Security group rules
  ingress = [
    { from_port : 137, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
    { from_port : 137, to_port : 139, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnet" },
  ]
  egress = [
    { from_port : 135, to_port : 135, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" }, 
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 135, to_port : 135, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" }, 
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", security_groups : [dependency.rds-trust.outputs.security_group_id], description : dependency.rds-trust.outputs.security_group_name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.rds-trust.outputs.security_group_id], description : dependency.rds-trust.outputs.security_group_name },
  ]
  # Target group settings
  tg_entries = {}
}
