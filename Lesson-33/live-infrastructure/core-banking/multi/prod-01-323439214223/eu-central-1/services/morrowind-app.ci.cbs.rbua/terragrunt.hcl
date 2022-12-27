include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}

iam_role = local.account_vars.iam_role

locals {
  aws_account_id  = local.account_vars.locals.aws_account_id
  current_tags    = read_terragrunt_config("tags.hcl")
  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags_map = local.common_tags.locals
  local_tags_map  = local.current_tags.locals
  tags_map        = merge(local.common_tags_map, local.local_tags_map)
  name            = basename(get_terragrunt_dir())
}

inputs = {
  name                    = local.name
  ami                     = "ami-03555de511cd01186"
  instance_type           = "r5b.4xlarge"
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[0]
  key_name                = dependency.vpc.outputs.ssh_key_ids[0]
  tags                    = local.tags_map
  volume_tags             = local.tags_map
  disable_api_termination = true
  monitoring              = true

  sg_ingress_rules = [
    {
      description = "RDP"
      from_port   = 3389
      to_port     = 3389
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "TCP"
      from_port   = 8443
      to_port     = 8443
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "TCP"
      from_port   = 9993
      to_port     = 9993
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "TCP"
      from_port   = 10101
      to_port     = 10101
      protocol    = "TCP"
      cidr_blocks = ["10.191.22.222/32"]
    }
  ]
  sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
