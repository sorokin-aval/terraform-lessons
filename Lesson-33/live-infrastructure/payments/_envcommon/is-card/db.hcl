dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "tpiimini-ap01" {
  config_path = find_in_parent_folders("tpiimini-ap01.is-card")
}

dependency "connector-ap01" {
  config_path = find_in_parent_folders("connector-ap01.is-card")
}

dependency "cnp-ap01" {
  config_path = find_in_parent_folders("cnp-ap01.is-card")
}

dependency "sortoutfile-ap01" {
  config_path = find_in_parent_folders("tm/sortoutfile-ap01.tm")
}

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssh"),
    find_in_parent_folders("cnp-ap01.is-card"),
    find_in_parent_folders("connector-ap01.is-card"),
    find_in_parent_folders("tpiimini-ap01.is-card"),
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
  ssh-key         = "DBRE"
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable", "general-is-card"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-02jxh2un5ckxhf" })
  # ebs_optimized   = false
  # Security group rules
  ingress = [
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card-aws"], description : "ho-pool-card-aws" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card"], description : "ho-pool-card" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir-aws"], description : "ho-pool-ho-dir-aws" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 20910, to_port : 20910, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnets-cidr-blocks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-system"], description : "on-premise-system" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nagios"], description : "nagios" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["data-catalog"], description : "data-catalog" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 20910, to_port : 20910, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 7006, to_port : 7006, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kiosk"], description : "kiosk" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["idm"], description : "idm" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db-subnets" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["blue-prism"], description : "blue-prism" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-internal"], description : "rbua-cbs-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-restricted"], description : "rbua-cbs-restricted" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["soda"], description : "soda" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-etl"], description : "ho-pool-etl" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight"], description : "ArcSight" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight-esm"], description : "arcsight-esm" },
    { from_port : 20910, to_port : 20910, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card-aws"], description : "ho-pool-card-aws" },
    { from_port : 1522, to_port : 1522, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zabbix"], description : "zabbix" },
    { from_port : 20910, to_port : 20910, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zabbix"], description : "zabbix" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-custacc-internal"], description : "rbua-custacc-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-internal"], description : "payments-prod-09-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-appstream-prod"], description : "rbua-appstream-prod" },
    { from_port : 20910, to_port : 20910, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card"], description : "ho-pool-card" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nifi-prod"], description : "nifi-prod" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ns"], description : "ho-pool-ns" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-internal"], description : "avalaunch-dev-mig-2k3h-internal" },
  ]

  egress = [
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["satellite"], description : "satellite" },
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 9094, to_port : 9094, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kafka-dmz"], description : "kafka-dmz" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 7005, to_port : 7006, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db-subnets" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-transfer"], description : "rbua-cbs-transfer" },
    { from_port : 15200, to_port : 15204, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15700, to_port : 15704, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1526, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["db3.odb"], description : "db3.odb" },
  ]
  # Target group settings
  tg_entries = {}
}
