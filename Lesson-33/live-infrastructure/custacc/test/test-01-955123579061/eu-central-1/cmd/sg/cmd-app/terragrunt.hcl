#custacc
include {
  path = find_in_parent_folders()
}

# Hardcode!
dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  #  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  source = local.account_vars.locals.sources["sg"]
  #  source = local.account_vars.locals.sources.sg
}

locals {
  #  name = basename(get_parent_terragrunt_dir())
  name        = "${upper(local.app_vars.locals.name)}-App"
  description = "security group for CMD APP servers access"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))

}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags = merge(local.app_vars.locals.tags, {
  })
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
      from_port   = 9443
      to_port     = 9443
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 8080
      to_port     = 8082
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 7443
      to_port     = 7443
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
