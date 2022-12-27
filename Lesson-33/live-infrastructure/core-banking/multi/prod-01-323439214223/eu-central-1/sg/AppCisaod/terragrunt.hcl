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
  name           = "AppCisaod"
  description    = "security group for Application of CISAOD"
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  current_tags    = read_terragrunt_config("tags.hcl")
  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  local_tags_map  = local.current_tags.locals
  tags_map        = merge(local.common_tags_map, local.local_tags_map)
}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.tags_map

  egress_with_cidr_blocks = [
    {
      "cidr_blocks" = "0.0.0.0/0"
      "description" = "no limit"
      "from_port"   = 0
      "protocol"    = "-1"
      "to_port"     = 0
    }
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks" = "0.0.0.0/0"
      "description" = "application port"
      "from_port"   = 8443
      "protocol"    = "tcp"
      "to_port"     = 8443
    },
    {
      "cidr_blocks" = "0.0.0.0/0"
      "description" = "process monitoring"
      "from_port"   = 9993
      "protocol"    = "tcp"
      "to_port"     = 9993
    },
    {
      description = "TCP"
      from_port   = 10101
      to_port     = 10101
      protocol    = "TCP"
      cidr_blocks = "10.191.22.222/32"
    }
  ]

}
