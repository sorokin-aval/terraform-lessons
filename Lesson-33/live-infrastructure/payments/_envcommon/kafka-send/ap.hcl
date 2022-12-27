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
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01v40dc2gbt7gl" })
  # Security group rules
  ingress = [
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 15202, to_port : 15202, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 15702, to_port : 15702, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["payments-prod-08-transfer"], description : "payments-prod-08-transfer" },
    { from_port : 9094, to_port : 9094, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-restricted"], description : "avalaunch-dev-mig-2k3h-restricted" },
  ]
  # Target group settings
  tg_entries = {}
}
