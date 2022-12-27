# Custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
  #  config_path = "../../core-infrastructure/vpc-info/"
}


terraform {
  source = local.account_vars.locals.sources["sg"]
  #  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {

  name        = basename(get_terragrunt_dir())
  description = "security group for CommVault media agent"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  #  tags = local.tags_map
  tags = merge(local.app_vars.locals.tags, {})

  ingress_with_cidr_blocks = [
    {
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.226.138.30/32"
    },

    {
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.191.2.184/32"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.191.2.184/32"
    },

    {
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.226.138.30/32"
    }
  ]
}
