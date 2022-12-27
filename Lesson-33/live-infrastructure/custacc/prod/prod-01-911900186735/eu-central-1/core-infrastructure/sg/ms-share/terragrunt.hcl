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

  name         = basename(get_terragrunt_dir())
  description  = "security group for MS-SHARE access"
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))

}


inputs = {
  name        = local.name
  description = local.description

  use_name_prefix     = false
  vpc_id              = dependency.vpc.outputs.vpc_id.id
  tags                = merge(local.app_vars.locals.tags, {})
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 135
      to_port     = 135
      protocol    = "tcp"
      description = "RPC"
    },
    {
      from_port   = 137
      to_port     = 138
      protocol    = "udp"
      description = "netbios"
    },
    {
      from_port   = 139
      to_port     = 139
      protocol    = "tcp"
      description = "NetBIOS Session Service"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "SMB"
    },

  ]

  egress_with_cidr_blocks = [
  ]
}
