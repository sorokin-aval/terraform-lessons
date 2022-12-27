include {
  path = find_in_parent_folders()
}

# Hardcode!
dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}
iam_role = local.account_vars.iam_role
locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  name        = basename(get_terragrunt_dir())
  description = "security group for GlassFish aka latino"

  #current_tags = read_terragrunt_config("tags.hcl")
  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  #local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map)

}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.tags_map

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 34150
      to_port     = 34162
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 34221
      to_port     = 34301
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 59082
      to_port     = 59094
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 7100
      to_port     = 7100
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 7200
      to_port     = 7200
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 7300
      to_port     = 7300
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 7400
      to_port     = 7400
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 7500
      to_port     = 7500
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8777
      to_port     = 8777
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9100
      to_port     = 9101
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9200
      to_port     = 9201
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      }, {
      from_port   = 9400
      to_port     = 9401
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = "10.191.5.107/32"
      description = "OIM"
    },

    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = "10.226.106.62/32"
      description = "from BPLU server"
    },

    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = "10.226.112.160/27"
      description = "OIM in AWS"
    },

    {
      from_port   = 21
      to_port     = 21
      protocol    = "tcp"
      cidr_blocks = "10.226.112.192/27"
      description = "OIM in AWS"
    },
    {
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }

  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]


}
