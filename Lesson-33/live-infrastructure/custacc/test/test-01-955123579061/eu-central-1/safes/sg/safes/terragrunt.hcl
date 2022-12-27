#custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {

  name        = basename(get_terragrunt_dir())
  description = "security group for SAFES servers access"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))

}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id

  tags = local.app_vars.locals.tags

  ingress_with_cidr_blocks = [
    {
      from_port   = 2638
      to_port     = 2652
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 2654
      to_port     = 2657
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 2661
      to_port     = 2661
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
  ]

  #  egress_with_cidr_blocks = [
  #        {
  #      name = "All"
  #      from_port   = 0
  #      to_port     = 0
  #      protocol    = "-1"
  #      description = "Allow all"
  #      cidr_blocks = "0.0.0.0/0"
  #    }
  #  ]
}
