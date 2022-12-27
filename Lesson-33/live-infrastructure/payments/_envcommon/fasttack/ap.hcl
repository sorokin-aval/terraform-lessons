dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb-sg-internal" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "alb-sg-external" { config_path = find_in_parent_folders("alb-external/sg") }
dependency "tg-alb-internal" { config_path = find_in_parent_folders("target-groups/tg-alb-internal") }
dependency "tg-alb-external" { config_path = find_in_parent_folders("target-groups/tg-alb-external") }

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
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-02p81fsm4c8yhx" })
  # Security group rules
  ingress = [
    { from_port : 13000, to_port : 13000, protocol : "tcp", security_groups : [dependency.alb-sg-internal.outputs.security_group_id], description : "alb-internal" },
    { from_port : 13000, to_port : 13000, protocol : "tcp", security_groups : [dependency.alb-sg-external.outputs.security_group_id], description : "alb-external" },
    { from_port : 13000, to_port : 13000, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["jump"], description : "jump" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "Visa, Mastercard public API access https://api.visa.com:443, https://api.mastercard.com:443/mdes/csapi/v2/" },
    { from_port : 15200, to_port : 15200, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15700, to_port : 15700, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mb"], description : "ibm-mb" },
    { from_port : 636, to_port : 636, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ad-test"], description : "ad-test" },
  ]
  # Target group settings
  tg_entries = {
    "int-443" = {
      target_port  = 13000
      target_group = dependency.tg-alb-internal.outputs.target_groups["int-443"].arn
    },
    "int-445" = {
      target_port  = 13000
      target_group = dependency.tg-alb-internal.outputs.target_groups["int-445"].arn
    },
    "external" = {
      target_port  = 13000
      target_group = dependency.tg-alb-external.outputs.target_groups["13000"].arn
    },
  }
}
