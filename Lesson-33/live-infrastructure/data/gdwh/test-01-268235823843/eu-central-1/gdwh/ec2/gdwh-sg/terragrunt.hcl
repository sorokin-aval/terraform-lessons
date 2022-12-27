include "account" {
  path = find_in_parent_folders("account.hcl")
}
include {
  path = find_in_parent_folders()
}
dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.13.0"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.project_vars.locals.resource_prefix}-${basename(get_terragrunt_dir())}"
}

dependency "gdwhasm" {
  config_path  = "../gdwhasm/"
  mock_outputs = {
    sg_id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

inputs = {
  name              = local.name
  create_sg         = false
  description       = "Security group for ${local.name}"
  vpc_id            = dependency.vpc.outputs.vpc_id.id
  security_group_id = dependency.gdwhasm.outputs.sg_id
  tags              = local.tags_map

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      description = "CyberArk pool ssh access"
      cidr_blocks = "10.191.242.32/28"
    },
    {
      from_port   = 1521
      to_port     = 1526
      protocol    = 6
      description = "Oracle B2 database"
      cidr_blocks = "10.227.44.223/32"
    },
    {
      from_port   = 1575
      to_port     = 1575
      protocol    = 6
      description = "Oracle B2 database"
      cidr_blocks = "10.227.44.223/32"
    },
    {
      from_port   = 1521
      to_port     = 1526
      protocol    = 6
      description = "HO-POOL-MESSAGEBROKER"
      cidr_blocks = "10.190.49.0/26"
    },
    {
      from_port   = 1575
      to_port     = 1575
      protocol    = 6
      description = "HO-POOL-MESSAGEBROKER"
      cidr_blocks = "10.190.49.0/26"
    },
    {
      from_port   = 1521
      to_port     = 1526
      protocol    = 6
      description = "HO-POOL-DBA"
      cidr_blocks = "10.190.62.128/26"
    },
    {
      from_port   = 1575
      to_port     = 1575
      protocol    = 6
      description = "HO-POOL-DBA"
      cidr_blocks = "10.190.62.128/26"
    },
    {
      from_port   = 1521
      to_port     = 1526
      protocol    = 6
      description = "HO-POOL-BI"
      cidr_blocks = "10.190.125.128/25"
    },
    {
      from_port   = 1575
      to_port     = 1575
      protocol    = 6
      description = "HO-POOL-BI"
      cidr_blocks = "10.190.125.128/25"
    }
  ]
  egress_with_cidr_blocks = [
    {
      name        = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
