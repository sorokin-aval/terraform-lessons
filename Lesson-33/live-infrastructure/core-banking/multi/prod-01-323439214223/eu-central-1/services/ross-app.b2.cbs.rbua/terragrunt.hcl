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
  name            = "ross-app.b2.cbs.rbua"
}

inputs = {
  name                    = local.name
  ami                     = "ami-025fb03af14ac192b"
  instance_type           = "t3.xlarge"
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[0]
  key_name                = dependency.vpc.outputs.ssh_key_ids[0]
  tags                    = local.tags_map
  volume_tags             = local.tags_map
  disable_api_termination = true
  monitoring              = true

  sg_ingress_rules = [
    {
      description = ""
      from_port   = 3389
      to_port     = 3389
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = ""
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
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
