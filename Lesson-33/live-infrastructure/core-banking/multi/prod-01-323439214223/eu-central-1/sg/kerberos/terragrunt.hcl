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
  description = "security group for kerberos"

  #current_tags = read_terragrunt_config("tags.hcl")
  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  #local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map)

}

inputs = {
  name            = local.name
  use_name_prefix = false
  description     = local.description
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.tags_map

  egress_with_cidr_blocks = [
    {
      "cidr_blocks" = "10.225.109.4/32"
      "from_port"   = 88
      "protocol"    = "tcp"
      "to_port"     = 88
      "description" = "aws.ms.aval"
    },
    {
      "cidr_blocks" = "10.225.109.20/32"
      "from_port"   = 88
      "protocol"    = "tcp"
      "to_port"     = 88
      "description" = "aws.ms.aval"
    }
  ]

}
