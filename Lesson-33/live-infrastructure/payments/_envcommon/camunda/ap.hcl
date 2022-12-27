dependency "ssm-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars          = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name              = basename(get_terragrunt_dir())
  avalaunch-account = local.account_vars.locals.environment == "test" ? "avalaunch-dev-mzwc-internal" : "avalaunch-dev-mig-2k3h-internal"
}

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = "${local.name}"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = local.app_vars.locals.tags
  # Security group rules
  ingress = [
    { from_port : 8443, to_port : 8443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 9999, to_port : 9999, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 8090, to_port : 8090, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 8091, to_port : 8091, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 9990, to_port : 9990, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 9993, to_port : 9993, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-app-admin"], description : "HO-POOL-APP_ADMIN" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intcritical-prod-01-internal"], description : "channels-intcritical-prod-01-internal" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["channels-intcritical-prod-01-internal"], description : "channels-intcritical-prod-01-internal" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 9080, to_port : 9200, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 7845, to_port : 7999, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 5067, to_port : 5067, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 8777, to_port : 8777, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 6699, to_port : 6699, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts[local.avalaunch-account], description : local.avalaunch-account },
    { from_port : 9094, to_port : 9094, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-restricted"], description : "avalaunch-dev-mig-2k3h-restricted" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1451, to_port : 1451, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 7800, to_port : 7850, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db-subnets" },
    { from_port : 7845, to_port : 7845, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 7850, to_port : 7850, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["broker"], description : "broker" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["was2jb"], description : "was2jb" },
    { from_port : 9094, to_port : 9094, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["kafka"], description : "kafka" },
  ]
  # Target group settings
  tg_entries = {
    "8443" = {
      target_port  = 8443
      target_group = dependency.tg-alb.outputs.target_groups["8443"].arn
    },
  }
}
