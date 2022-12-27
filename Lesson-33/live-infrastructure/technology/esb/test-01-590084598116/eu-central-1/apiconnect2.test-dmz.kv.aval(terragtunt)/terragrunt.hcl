include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//.?ref=main"
}

dependency "vpc" {
  config_path  = find_in_parent_folders("test-01-590084598116/eu-central-1/core-infrastructure/baseline")
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  name                    = local.name
  #Set Image ID for your server here
  ami                     = "ami-002fa4d6a37d9dcb1"
  #Set instance type for your server here
  instance_type           = "t3a.medium"
  ebs_optimized           = true
  disable_api_termination = true
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[0]
  key_name                = "platformOps"
  tags                    = merge(local.common_tags.locals, {
    map-migrated = "d-server-00yjkv4nkmx63z"
  })
  #Rules to allow access to server.
  sg_ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
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

