#
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
#  config_path = "../core-infrastructure/vpc-info/"
}
iam_role = local.account_vars.iam_role

terraform {
#  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//terraform-aws-security-group?ref=main"
#  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  source = local.account_vars.locals.sources["sg"]
#  source = local.account_vars.locals.sources.sg

}

  locals {
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))
    name        = basename(get_terragrunt_dir())
  }


inputs = {
  name        = local.name
  description = "Security group for test"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags   = local.app_vars.locals.tags

  ingress_with_cidr_blocks = [
    {
      name        = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Test sg_rule inbound"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      name        = "All ports"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "test sg_rule outbound"
      cidr_blocks = "0.0.0.0/0"
#      source_security_group_id = dependency.sg.outputs.security_group_id
    },
  ]
}