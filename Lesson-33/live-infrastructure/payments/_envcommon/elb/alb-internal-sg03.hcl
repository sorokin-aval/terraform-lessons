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

  ingress_cidr_blocks = concat(
    local.account_vars.locals.pools["ho-pool-card"],
    local.account_vars.locals.pools["ho-pool-card-aws"],
    local.account_vars.locals.pools["ho-pool-opc10"],
    local.account_vars.locals.pools["ho-pool-fairo"],
    local.account_vars.locals.pools["ho-pool-ho-dir"],
    local.account_vars.locals.pools["ho-pool-ho-dir-aws"],
    local.account_vars.locals.ips["ibm-mb"],
  )
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
    },
  ]

  egress_cidr_blocks = concat(
    dependency.vpc.outputs.app_subnet_cidr_blocks,
    dependency.vpc.outputs.lb_subnet_cidr_blocks,
    dependency.vpc.outputs.db_subnet_cidr_blocks,
  )
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
    { map-migrated = "d-server-020b2954batpyz" }
  )
}
