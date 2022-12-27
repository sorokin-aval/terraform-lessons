dependency "smtp-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars           = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars               = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name                   = basename(get_terragrunt_dir())
  payments_0308_internal = local.account_vars.locals.environment == "test" ? "payments-test-03-internal" : "payments-prod-08-internal"
}

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  security_groups = ["ad", "ssh", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-02luv3a46iqraw" })
  # Security group rules
  ingress = [
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "SMTP" },
    { from_port : 25, to_port : 25, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["vip-inet-dmz"], description : "SMTP" },
  ]
  egress = [
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
  ]
  # Target group settings
  tg_entries = {}
}
