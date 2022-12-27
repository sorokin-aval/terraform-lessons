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

  ingress_cidr_blocks = ["10.0.0.0/8"] # HO-POOL-CARD
  ingress_with_cidr_blocks = [
    {
      from_port   = 9443
      to_port     = 9443
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9043
      to_port     = 9043
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9400
      to_port     = 9400
      protocol    = "tcp"
      description = "HTTPS VPOS"
    },
    {
      from_port   = 9080
      to_port     = 9080
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9044
      to_port     = 9044
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 9500
      to_port     = 9500
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 8777
      to_port     = 8777
      protocol    = "tcp"
      description = "HTTPS"
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "HTTPS"
    },
  ]

  egress_with_cidr_blocks = [
    {
      name        = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-020b2954batpyz" }
  )
}
