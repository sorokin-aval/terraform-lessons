include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//.?ref=main"
}

dependency "vpc" {
  config_path  = find_in_parent_folders("prod-01-136812256255/eu-central-1/core-infrastructure/baseline")
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
  ami                     = "ami-0ddd1611ede529765"
  #Set instance type for your server here
  instance_type           = "t3a.small"
  ebs_optimized           = true
  disable_api_termination = true
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[1]
  key_name                = "platformOps"
  tags                    = merge(local.common_tags.locals, {
    custom_tag   = "builder2 cmd",
    map-migrated = "d-server-00ql5olrsu9h2i",
    MAPProjectid = "MPE32598"
  })
  #Rules to allow access to server. In this example allowed access on port 8080 because application open this port
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
