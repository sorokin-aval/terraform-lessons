#custacc
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
#  config_path = "../../core-infrastructure/vpc-info/"
}
iam_role = local.account_vars.iam_role

terraform {
#  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//terraform-aws-security-group//.?ref=v4.9.0"
  source = local.account_vars.locals.sources["sg"]
#  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

  locals {
#    common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))
#   app_vars    = read_terragrunt_config(find_in_parent_folders("core-infrastructure/application.hcl"))
#    tags_map = local.common_tags.locals

    name        = basename(get_terragrunt_dir())
#    name         = "launch-wizard-1"
  }


inputs = {
  use_name_prefix = false
  name        = local.name
  description = "Security group for ORACLE DB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags   = local.app_vars.locals.tags

  ingress_with_cidr_blocks = [
    {
#      name        = "POOLMEDOC-MEDOC"
      from_port   = 1521
      to_port     = 1526
      protocol    = "tcp"
      description = "OracleDB"
      cidr_blocks = "10.0.0.0/8"
    },
    {
#      name        = "POOLHODIR-40-MEDOC"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = ""
      cidr_blocks = "10.0.0.0/8"
    },
    {
#      name        = "AWS-TRN-B-MEDOC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "10.0.0.0/8"
    }
  ]
   egress_with_cidr_blocks = [
  ]
}