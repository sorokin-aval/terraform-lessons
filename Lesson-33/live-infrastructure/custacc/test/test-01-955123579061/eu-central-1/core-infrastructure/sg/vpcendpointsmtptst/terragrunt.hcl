#custacc
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}
iam_role = local.account_vars.iam_role


terraform {
  source = local.account_vars.locals.sources["sg"]
#  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {

  name = basename(get_terragrunt_dir())
  description = "security group for SES servers access"

    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))

  #current_tags = read_terragrunt_config("tags.hcl")
#  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
#  common_tags_map = local.common_tags.locals
  #local_tags_map = local.current_tags.locals
#  tags_map = merge(local.common_tags_map,
#  { application_role = "HO-BAPP-SAFES"}
#  )

}

inputs = {
#  name = local.name
  name = "VpcEndpointSmtpTst" 
  description = local.description

  use_name_prefix = false
  vpc_id   = dependency.vpc.outputs.vpc_id.id
#  tags = local.tags_map
  tags   = local.app_vars.locals.tags
  ingress_with_cidr_blocks = [
#    {
#      from_port   = 465
#      to_port     = 465
#      protocol    = "tcp"
#      cidr_blocks = "10.226.138.5/32"
#    },
#    {
#      from_port   = 25
#      to_port     = 25
#      protocol    = "tcp"
#      cidr_blocks = "/32"
#    },
#    {
#      from_port   = 587
#      to_port     = 587
#      protocol    = "tcp"
#      cidr_blocks = "10.226.138.5/32"
#    },
    {
      from_port   = 465
      to_port     = 465
      protocol    = "tcp"
      cidr_blocks = "10.226.129.19/32"
    },
    {
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      cidr_blocks = "10.226.129.19/32"
    },
    {
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      cidr_blocks = "10.226.129.19/32"
    },
# cmd-web01
    {
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      cidr_blocks = "10.226.129.31/32"
    },
    {
      from_port   = 465
      to_port     = 465
      protocol    = "tcp"
      cidr_blocks = "10.226.129.31/32"
    },
    {
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      cidr_blocks = "10.226.129.31/32"
    },
#web-cmd-dev
    {
      from_port   = 465
      to_port     = 465
      protocol    = "tcp"
      cidr_blocks = "10.226.129.89/32"
    },
    {
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      cidr_blocks = "10.226.129.89/32"
    },
    {
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      cidr_blocks = "10.226.129.89/32"
    },
  ]

  egress_with_cidr_blocks = [
        {
      name = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "10.0.0.0/8"
    }
  ]
}
