include {
  path = find_in_parent_folders()
}

# Hardcode!
dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc_info")
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

iam_role = local.account_vars.iam_role

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  name = basename(get_terragrunt_dir())
  description = "security group for CommVault media agent"

  #current_tags = read_terragrunt_config("tags.hcl")
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  #local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map)

}

inputs = {
  name = local.name
  description = local.description

  use_name_prefix = false
  vpc_id   = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  ingress_with_cidr_blocks = [
    {
      from_port   = 8400
      to_port     = 8400
      protocol    = "tcp"
      cidr_blocks = "10.226.130.233/32"
    },

    {
      from_port   = 8403
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.226.130.233/32"
    },
   {
      from_port   = 8400
      to_port     = 8400
      protocol    = "tcp"
      cidr_blocks = "10.191.2.0/23"
    },

    {
      from_port   = 8403
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.191.2.0/23"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 8400
      to_port     = 8400
      protocol    = "tcp"
      cidr_blocks = "10.191.2.184/32"
    },

    {
      from_port   = 8403
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.191.2.184/32"
    },
    {
      from_port   = 8400
      to_port     = 8400
      protocol    = "tcp"
      cidr_blocks = "10.226.130.233/32"
    },

    {
      from_port   = 8403
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.226.130.233/32"
    },
   {
      from_port   = 8400
      to_port     = 8400
      protocol    = "tcp"
      cidr_blocks = "10.191.2.0/23"
    },

    {
      from_port   = 8403
      to_port     = 8403
      protocol    = "tcp"
      cidr_blocks = "10.191.2.0/23"
    }
  ]
}
