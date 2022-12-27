dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint"),
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("alb-internal/sg"),
    find_in_parent_folders("tg-alb"),
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
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-020t58kik2o1xb" })
  # Security group rules
  ingress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 15205, to_port : 15205, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15705, to_port : 15705, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
    { from_port : 389, to_port : 389, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ldap-kdc"], description : "ldap-kdc" },
    { from_port : 4100, to_port : 4100, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["vic-sdb"], description : "vic-sdb" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["esb-tap01"], description : "esb-tap01" },
    { from_port : 1416, to_port : 1416, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["swiftz"], description : "swiftz" },
  ]
  # Target group settings
  tg_entries = {
    "443" = {
      target_port  = 443
      target_group = dependency.tg-alb.outputs.target_groups["443"].arn
    },
  }
}
