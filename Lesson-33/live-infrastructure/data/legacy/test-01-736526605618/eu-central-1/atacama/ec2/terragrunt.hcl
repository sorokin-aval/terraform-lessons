## terragrunt.hcl
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

dependency "vpc" {
  config_path = "../../core-infrastructure/imported-vpc/"
}

dependency "iam_role" {
  config_path  = "../iam/iam_assumable_role/rbua-data-test-atacama"
  mock_outputs = {
    iam_role_name = "test-role"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.project_vars.locals.resource_prefix}"
}

inputs = {
  name                  = local.name
  ami                   = "ami-0547bc6092878c950"
  instance_type         = "r5n.large"
  ebs_optimized         = true
  subnet_id             = dependency.vpc.outputs.app_subnets.ids[0]
  key_name              = "atacama"
  attach_ebs            = true
  ebs_availability_zone = "eu-central-1b"
  ebs_type              = "gp3"
  ebs_size_gb           = 75
  create_iam_role_ssm   = false
  iam_instance_profile  = dependency.iam_role.outputs.iam_role_name
  tags                  = merge(local.tags_map, { Backup = "Weekly-4Week-Retention" })

  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.32/28"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.45/32"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.10/32"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.35/32"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.36/32"]
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "TCP"
      cidr_blocks = ["10.190.62.128/26"]
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "TCP"
      cidr_blocks = ["10.190.61.192/26", "10.190.131.0/26"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = ["10.190.61.192/26", "10.190.131.0/26"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.190.61.192/26", "10.190.131.0/26"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = ["10.191.208.0/20"]
    },
    {
      from_port   = 8777
      to_port     = 8777
      protocol    = "TCP"
      cidr_blocks = ["10.190.61.192/26", "10.190.131.0/26"]
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
