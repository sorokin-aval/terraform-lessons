dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

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
  security_groups = ["ad", "rdp", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-00m1lqv9hd4rj7" })
  # Security group rules
  ingress = [
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 15201, to_port : 15201, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-test-05-transfer"], description : "payments-test-05-transfer" },
    { from_port : 15201, to_port : 15201, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-09-transfer"], description : "payments-prod-09-transfer" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-transfer"], description : "cbs-prod-01-transfer" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["data-dev-02-internal"], description : "data-dev-02-internal" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 2638, to_port : 2638, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-transfer"], description : "channels-intnoncritical-prod-02-transfer" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["r-bm.todb"], description : "r-bm.todb" },
    { from_port : 2651, to_port : 2651, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["sheriff.tsdb"], description : "sheriff.tsdb" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["new-redbull.test"], description : "new-redbull.test" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["new-redbull.test"], description : "new-redbull.test" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["door"], description : "door" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["drive-g"], description : "drive-g" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-test-02-transfer"], description : "channels-intnoncritical-test-02-transfer" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-test-02-transfer"], description : "channels-intnoncritical-test-02-transfer" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-test-02-internal"], description : "channels-intnoncritical-test-02-internal" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-test-02-internal"], description : "channels-intnoncritical-test-02-internal" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-internal"], description : "channels-intnoncritical-prod-02-internal" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intnoncritical-prod-02-internal"], description : "channels-intnoncritical-prod-02-internal" },
  ]
  # Target group settings
  tg_entries = {}
}
