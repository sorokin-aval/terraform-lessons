dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "ap01" { config_path = find_in_parent_folders("ap01.${local.app_vars.locals.name}") }
dependency "ap02" { config_path = find_in_parent_folders("ap02.${local.app_vars.locals.name}") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("ap01.${local.app_vars.locals.name}"),
    find_in_parent_folders("ap02.${local.app_vars.locals.name}"),
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
  subnet          = "LZ-RBUA_Payments_*-RestrictedA"
  zone            = "eu-central-1a"
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "ssh", "observable", "${dependency.sg.outputs.security_group_name}"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-020zya2d8ytar8" })
  # Security group rules
  ingress = [
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.ap01.outputs.ec2_private_ip}/32"], description : dependency.ap01.outputs.name },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.ap02.outputs.ec2_private_ip}/32"], description : dependency.ap02.outputs.name },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-inex"], description : "oracle-db-inex" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-broker"], description : "ho-pool-broker" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["soda"], description : "soda" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ms-sql-report-server"], description : "ms-sql-report-server" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["gdwh"], description : "gdwh" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-internal"], description : "nifi" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["data-dev-02-internal"], description : "DataStage" },
 ]
  egress  = [
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-inex"], description : "oracle-db-inex" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
  ]
  # Target group settings
  tg_entries = {}
}
