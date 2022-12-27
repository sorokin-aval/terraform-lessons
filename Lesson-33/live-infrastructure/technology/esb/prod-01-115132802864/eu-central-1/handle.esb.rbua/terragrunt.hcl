include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//.?ref=main"
}

dependency "vpc" {
  config_path  = find_in_parent_folders("prod-01-115132802864/eu-central-1/core-infrastructure/baseline")
  mock_outputs = {
    ids = ["subnet-00000000000000000"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  name                    = local.name
  #Set Image ID for your server here
  ami                     = "ami-004198d8e1145e205"
  #Set instance type for your server here
  instance_type           = "t3a.nano"
  ebs_optimized           = true
  disable_api_termination = true
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[1]
  key_name                = "esb_prod"
  tags                    = merge(local.common_tags.locals, {
    map-migrated = "d-server-01j117r40h8tjl"
  })
  #Rules to allow access to server.
  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
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

