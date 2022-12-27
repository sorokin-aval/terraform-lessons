#
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))

  name = basename(get_terragrunt_dir())
}

inputs = {
  name        = local.name
  description = "Security group used for web-cmd auth and SES mail"

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags = merge(local.app_vars.locals.tags, {
  })

  egress_ipv6_cidr_blocks = []

  egress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "10.225.121.22/32"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "10.225.121.191/32"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "10.225.122.88/32"
    },
    {
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      cidr_blocks = "10.225.102.26/32"
      #      description = "SES mail"
    }
  ]
}
