#custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

# Hardcode!
dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
  #  config_path = "../../core-infrastructure/vpc-info/"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {

  name        = basename(get_terragrunt_dir())
  description = "security group for KRD-WEB servers access"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  tags_map = merge(local.app_vars.locals.tags,
    {}
  )

}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.tags_map

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 1230
      to_port     = 1238
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 4011
      to_port     = 4011
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 2638
      to_port     = 2655
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 5001
      to_port     = 5010
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    }
  ]

  egress_with_cidr_blocks = [
    #        {
    #      name = "All"
    #      from_port   = 0
    #      to_port     = 0
    #      protocol    = "-1"
    #      description = "Allow all"
    #      cidr_blocks = "0.0.0.0/0"
    #    }
  ]
}
