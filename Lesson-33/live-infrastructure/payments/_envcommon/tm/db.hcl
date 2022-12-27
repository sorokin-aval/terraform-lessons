dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "smtp-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "shovel-ap01" {
  config_path = find_in_parent_folders("shovel-ap01.tm")
}

dependency "sortoutfile-ap01" {
  config_path = find_in_parent_folders("sortoutfile-ap01.tm")
}

dependency "web-ap01" {
  config_path = find_in_parent_folders("web-ap01.tm")
}

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssh"),
    find_in_parent_folders("shovel-ap01.tm"),
    find_in_parent_folders("sortoutfile-ap01.tm"),
    find_in_parent_folders("web-ap01.tm"),
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
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable", "general-tm-1", "general-tm-2"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-031nyqkrupyhp4" })
  # Security group rules
  ingress = [
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "ho-pool-dba" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card-aws"], description : "ho-pool-card-aws" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card"], description : "ho-pool-card" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir-aws"], description : "ho-pool-ho-dir-aws" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    # { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.shovel-ap01.outputs.ec2_private_ip}/32", "${dependency.sortoutfile-ap01.outputs.ec2_private_ip}/32", "${dependency.web-ap01.outputs.ec2_private_ip}/32"], description : "shovel-ap01, sortoutfile-ap01, web-ap01" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "app-subnets-cidr-blocks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["biffit-lb"], description : "biffit-lb" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ibm-mb"], description : "ibm-mb" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-system"], description : "on-premise-system" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nagios"], description : "nagios" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rinfo-app"], description : "rinfo-app" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rinfo-app-on-premise"], description : "rinfo-app-on-premise" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-sft"], description : "ho-pool-sft" },
    # { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nifi"], description : "nifi" }, # only test
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["data-catalog"], description : "data-catalog" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kiosk"], description : "kiosk" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["idm"], description : "idm" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["vip"], description : "vip" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kiosk-app"], description : "kiosk-app" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["gamma"], description : "gamma" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["blue-prism"], description : "blue-prism" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["debt-manager"], description : "debt-manager" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-internal"], description : "rbua-cbs-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-restricted"], description : "rbua-cbs-restricted" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["soda"], description : "soda" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-etl"], description : "ho-pool-etl" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight"], description : "ArcSight" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight-esm"], description : "arcsight-esm" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["cbtp-pool"], description : "CBTP Pool" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1522, to_port : 1522, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zabbix"], description : "zabbix" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wtech"], description : "uadho-wtech" },
    { from_port : 1521, to_port : 1522, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-custacc-internal"], description : "rbua-custacc-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dbKioskDblinks"], description : "dbKioskDblinks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["vip.inet-dmz"], description : "vip.inet-dmz" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-le"], description : "ho-pool-le" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nifi"], description : "nifi" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-internal"], description : "payments-prod-09-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-appstream-prod"], description : "rbua-appstream-prod" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ns"], description : "ho-pool-ns" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-restricted"], description : "payments-prod-09-restricted" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-restricted"], description : "payments-prod-09-restricted" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rinfo-dev"], description : "rinfo-dev" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["floyd.todb"], description : "floyd.todb" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["datastage"], description : "datastage" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-internal"], description : "avalaunch-dev-mig-2k3h-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["tenable"], description : "tenable" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-devpay"], description : "ho-pool-devpay" },
    { from_port : 1521, to_port : 1522, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dm-odb02"], description : "dm-odb02" },
  ]
  egress = [
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["satellite"], description : "satellite" },
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db-subnets" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["newtm-in-data"], description : "newtm-in-data" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["rbua-cbs-restricted"], description : "rbua-cbs-restricted" },
    { from_port : 15200, to_port : 15204, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 15700, to_port : 15704, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 15203, to_port : 15203, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-transfer"], description : "payments-prod-09-transfer" },
    { from_port : 15703, to_port : 15703, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-transfer"], description : "payments-prod-09-transfer" },
  ]
  # Target group settings
  tg_entries = {}
}
