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
  subnet          = "LZ-RBUA_Payments_*-RestrictedA"
  zone            = "eu-central-1a"
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "ssh", "observable", "${dependency.sg.outputs.security_group_name}"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01wfdcn2jk11g1" })
  # Security group rules
  ingress = [
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-alfa"], description : "oracle-db-alfa" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["commondoor"], description : "commondoor" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["commondoor"], description : "commondoor" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-internal"], description : "payments-prod-08-internal" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-internal"], description : "payments-prod-08-internal" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-restricted"], description : "payments-prod-08-restricted" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-restricted"], description : "payments-prod-08-restricted" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["gamma"], description : "gamma" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["gamma"], description : "gamma" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kiosk"], description : "kiosk" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kiosk"], description : "kiosk" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card"], description : "ho-pool-card" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-card"], description : "ho-pool-card" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["multipool"], description : "multipool" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["multipool"], description : "multipool" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["leftpool"], description : "leftpool" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["leftpool"], description : "leftpool" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rightpool"], description : "rightpool" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rightpool"], description : "rightpool" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-vpps"], description : "ho-pool-vpps" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-lits"], description : "ho-pool-lits" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-lits"], description : "ho-pool-lits" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["technology-prod-internal"], description : "technology-prod-internal" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["technology-prod-internal"], description : "technology-prod-internal" },    
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], description : "cbs-prod-01-internal" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wtech"], description : "uadho-wtech" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wtech"], description : "uadho-wtech" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["leftnew"], description : "leftnew" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["leftnew"], description : "leftnew" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["left2new"], description : "left2new" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["left2new"], description : "left2new" },    
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-treasury"], description : "ho-pool-treasury" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-treasury"], description : "ho-pool-treasury" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-broker"], description : "ho-pool-broker" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-broker"], description : "ho-pool-broker" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["data-internal-b"], description : "data-internal-b" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["data-internal-b"], description : "data-internal-b" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["legacy-prod-01-internal"], description : "legacy-prod-01-internal" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["legacy-prod-01-internal"], description : "legacy-prod-01-internal" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cybersecurity-iam-prod-internal"], description : "cybersecurity-iam-prod-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["custacc-prod-01-internal"], description : "custacc-prod-01-internal" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["debt-sale"], description : "debt-sale" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mbank"], description : "mbank" },
  ]
  egress  = [
    { from_port : 1521, to_port : 1526, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-alfa"], description : "oracle-db-alfa" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["oracle-db-alfa"], description : "oracle-db-alfa" },
    { from_port : 15203, to_port : 15203, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 15703, to_port : 15703, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 139, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["hnas"], description : "hnas" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "commvault" },
  ]
  # Target group settings
  tg_entries = {}
}
