dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("alb-internal/alb"),
    find_in_parent_folders("alb-internal/sg"),
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("tg-alb"),
    find_in_parent_folders("acm"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars        = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name            = basename(get_terragrunt_dir())
  payments_part01 = local.account_vars.locals.environment == "test" ? "payments-test-03-transfer" : "payments-prod-08-transfer"
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
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01bgl4aumr8kuo" })
  # Security group rules
  ingress = [
    { from_port : 9100, to_port : 9500, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 8777, to_port : 8777, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 8777, to_port : 8777, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 7100, to_port : 7100, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 7200, to_port : 7200, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 7300, to_port : 7300, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 7400, to_port : 7400, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 7500, to_port : 7500, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9100, to_port : 9100, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9200, to_port : 9200, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9300, to_port : 9300, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9400, to_port : 9400, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 9500, to_port : 9500, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-payments"], description : "ho-pool-payments" },
    { from_port : 8777, to_port : 8777, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 9100, to_port : 9100, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 9200, to_port : 9200, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 9300, to_port : 9300, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 9400, to_port : 9400, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 9500, to_port : 9500, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-opc10"], description : "ho-pool-opc10" },
    { from_port : 8777, to_port : 8777, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 9100, to_port : 9100, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 9200, to_port : 9200, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 9300, to_port : 9300, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 9400, to_port : 9400, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 9500, to_port : 9500, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-ho-dir"], description : "ho-pool-ho-dir" },
    { from_port : 8777, to_port : 8777, protocol : "tcp", cidr_blocks : local.account_vars.locals.environment != "test" ? ["127.0.0.1/32"] : concat(local.account_vars.locals.ips["oslo"], local.account_vars.locals.ips["monaco"], local.account_vars.locals.ips["bamboo"], local.account_vars.locals.ips["spscrum"]), description : "oslo, monaco, bamboo, spscrum" },
    { from_port : 9100, to_port : 9100, protocol : "tcp", cidr_blocks : local.account_vars.locals.environment != "test" ? ["127.0.0.1/32"] : concat(local.account_vars.locals.ips["oslo"], local.account_vars.locals.ips["monaco"], local.account_vars.locals.ips["bamboo"], local.account_vars.locals.ips["spscrum"]), description : "oslo, monaco, bamboo, spscrum" },
    { from_port : 9200, to_port : 9200, protocol : "tcp", cidr_blocks : local.account_vars.locals.environment != "test" ? ["127.0.0.1/32"] : concat(local.account_vars.locals.ips["oslo"], local.account_vars.locals.ips["monaco"], local.account_vars.locals.ips["bamboo"], local.account_vars.locals.ips["spscrum"]), description : "oslo, monaco, bamboo, spscrum" },
    { from_port : 9300, to_port : 9300, protocol : "tcp", cidr_blocks : local.account_vars.locals.environment != "test" ? ["127.0.0.1/32"] : concat(local.account_vars.locals.ips["oslo"], local.account_vars.locals.ips["monaco"], local.account_vars.locals.ips["bamboo"], local.account_vars.locals.ips["spscrum"]), description : "oslo, monaco, bamboo, spscrum" },
    { from_port : 9400, to_port : 9400, protocol : "tcp", cidr_blocks : local.account_vars.locals.environment != "test" ? ["127.0.0.1/32"] : concat(local.account_vars.locals.ips["oslo"], local.account_vars.locals.ips["monaco"], local.account_vars.locals.ips["bamboo"], local.account_vars.locals.ips["spscrum"]), description : "oslo, monaco, bamboo, spscrum" },
    { from_port : 9500, to_port : 9500, protocol : "tcp", cidr_blocks : local.account_vars.locals.environment != "test" ? ["127.0.0.1/32"] : concat(local.account_vars.locals.ips["oslo"], local.account_vars.locals.ips["monaco"], local.account_vars.locals.ips["bamboo"], local.account_vars.locals.ips["spscrum"]), description : "oslo, monaco, bamboo, spscrum" },
  ]
  egress = [
    { from_port : 15202, to_port : 15203, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.payments_part01], description : local.payments_part01 },
    { from_port : 15702, to_port : 15703, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.payments_part01], description : local.payments_part01 },
    { from_port : 1521, to_port : 1526, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-transfer"], description : "cbs-prod-01-transfer" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-transfer"], description : "cbs-prod-01-transfer" },
    { from_port : 1521, to_port : 1535, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-restricted"], description : "cbs-prod-01-restricted" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["cbs-prod-01-restricted"], description : "cbs-prod-01-restricted" },
    { from_port : 1521, to_port : 1532, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["data-dev-02-internal"], description : "data-dev-02-internal" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["data-dev-02-internal"], description : "data-dev-02-internal" },
    { from_port : 1521, to_port : 1539, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["technology-prod-internal"], description : "rbua-technology-prod-internal" },
  ]
  # Target group settings
  tg_entries = {
    "9100" = {
      target_port  = 9100
      target_group = dependency.tg-alb.outputs.target_groups["9100"].arn
    },
    "9200" = {
      target_port  = 9200
      target_group = dependency.tg-alb.outputs.target_groups["9200"].arn
    },
    "9300" = {
      target_port  = 9300
      target_group = dependency.tg-alb.outputs.target_groups["9300"].arn
    },
    "9400" = {
      target_port  = 9400
      target_group = dependency.tg-alb.outputs.target_groups["9400"].arn
    },
    "9500" = {
      target_port  = 9500
      target_group = dependency.tg-alb.outputs.target_groups["9500"].arn
    },
    "8777" = {
      target_port  = 8777
      target_group = dependency.tg-alb.outputs.target_groups["8777"].arn
    },
  },
}
