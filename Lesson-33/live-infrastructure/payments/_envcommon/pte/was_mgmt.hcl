dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "smtp-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }

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

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = "${local.name}-v.0.01"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-00b1v9pkseprju" })
  # Security group rules
  ingress = [
    { from_port : 2000, to_port : 9999, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${dependency.sg.outputs.security_group_name} security group" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "HO-POOL-PAYMENTS" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card"], description : "HO-POOL-CARD" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "HO-POOL-DBA" },
    { from_port : 9043, to_port : 9043, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 2000, to_port : 9999, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${dependency.sg.outputs.security_group_name} security group" },
    { from_port : 22, to_port : 22, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${dependency.sg.outputs.security_group_name} SSH" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["osa12x.test-dmz"], description : "osa12x.test-dmz.kv.aval" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ose12x.todb"], description : "ose12x.todb.kv.aval" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["yakus"], description : "yakus.app.kv.aval" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mb"], description : "ibm-mb" },
    { from_port : 15203, to_port : 15204, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15703, to_port : 15704, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15200, to_port : 15200, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15700, to_port : 15700, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 389, to_port : 389, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["test.aval"], description : "test.aval" },
    { from_port : 636, to_port : 636, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["test.aval"], description : "test.aval" },
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "db01.pte, db01.vpos" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "db01.pte, db01.vpos" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rhui3"], description : "rhui3" },
    { from_port : 9081, to_port : 9081, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
    { from_port : 52311, to_port : 52311, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mcduck.noc-dc1"], description : "mcduck.noc-dc1" },
  ]

  # Target group settings
  tg_entries = {
    "pte-9043" = {
      target_port  = 9043
      target_group = dependency.tg-alb.outputs.target_groups["pte-9043"].arn
    },
  }
}
