dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = basename(dirname(find_in_parent_folders("sg")))
}

inputs = {
  name            = local.name
  use_name_prefix = false
  description     = "Security group for ${local.name}"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = merge(local.account_vars.locals.tags, { Name = "${local.name}" })

  ingress_cidr_blocks = local.account_vars.locals.ips["cloudflare-ips"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
    },
  ]

  egress_cidr_blocks = dependency.vpc.outputs.app_subnet_cidr_blocks
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Local network"
    }
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "", ccoe-inet-in-name = "alb-external" }
  )
}
