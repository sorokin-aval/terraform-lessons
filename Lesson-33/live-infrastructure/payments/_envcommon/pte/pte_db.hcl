dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "was-ap01" {
  config_path = find_in_parent_folders("was-ap01.pte")
}

dependency "was-ap02" {
  config_path = find_in_parent_folders("was-ap02.pte")
}

dependency "was-ap03" {
  config_path = find_in_parent_folders("was-ap03.pte")
}

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
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  ssh-key         = "DBRE"
  security_groups = ["ad", "ssh", "observable", "${dependency.sg.outputs.security_group_name}"]
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01lco9kahq76l2" })
  ebs_optimized   = false
  # Security group rules
  ingress = [
    { from_port : 1521, to_port : 1526, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "DBRE VDI pool" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"], description : "DBRE VDI pool" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "HO-POOL-PAYMENTS" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "HO-POOL-PAYMENTS" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight"], description : "ArcSight" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["arcsight"], description : "ArcSight" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.lb_subnet_cidr_blocks, description : "lb-subnet-cidr-blocks" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : ["${dependency.was-ap01.outputs.ec2_private_ip}/32"], description : dependency.was-ap01.outputs.name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.was-ap01.outputs.ec2_private_ip}/32"], description : dependency.was-ap01.outputs.name },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : ["${dependency.was-ap02.outputs.ec2_private_ip}/32"], description : dependency.was-ap02.outputs.name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.was-ap02.outputs.ec2_private_ip}/32"], description : dependency.was-ap02.outputs.name },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : ["${dependency.was-ap03.outputs.ec2_private_ip}/32"], description : dependency.was-ap03.outputs.name },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : ["${dependency.was-ap03.outputs.ec2_private_ip}/32"], description : dependency.was-ap03.outputs.name },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["aval-common-test"], description : "aval-common-test" },
    # only prod
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nagios"], description : "nagios" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wctm901"], description : "uadho-wctm901" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["zuko"], description : "zuko" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["mirinda"], description : "mirinda" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-etl"], description : "ho-pool-etl" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-etl"], description : "ho-pool-etl" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["control-m"], description : "control-m" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["test-qa"], description : "test-qa" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["data-catalog"], description : "data-catalog" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ns"], description : "ho-pool-ns" },
    { from_port : 1521, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-internal"], description : "avalaunch-dev-mig-2k3h-internal" },
  ]
  egress = [
    { from_port : 1521, to_port : 1526, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "${local.app_vars.locals.name}-sg" },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["on-premise-databases"], description : "on-premise-databases" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["satellite"], description : "satellite" },
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["rhui3"], description : "rhui3" },
    #only prod
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
  ]
  # Target group settings
  tg_entries = {}
}
