include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "sg_ap" {
  config_path = "../ap/"
  mock_outputs = {
    mock_outputs_allowed_terraform_commands = ["plan"]
    security_group_id                       = "sg-12345678901234567"
  }
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.tags_map.Project}-${local.tags_map.Environment}-${basename(get_terragrunt_dir())}"
}

inputs = {
  name        = local.name
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      description = "SSH access from CyberArk"
      cidr_blocks = "10.191.242.32/28"
    },
    {
      rule        = "ssh-tcp"
      description = "SSH access from Linux Admins server"
      cidr_blocks = "10.225.112.126/32"
    },
    {
      rule        = "ssh-tcp"
      description = "SSH access from HO-POOL-DBA"
      cidr_blocks = "10.190.62.128/26"
    },
    {
      rule        = "oracle-db-tcp"
      description = "Access from HO-POOL-DBA to BARS Stat DB"
      cidr_blocks = "10.190.62.128/26"
    },
    {
      rule        = "oracle-db-tcp"
      description = "Access from Data Domain VDI Poll to BARS Stat DB"
      cidr_blocks = "10.190.131.0/26"
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "oracle-db-tcp"
      description              = "Access from BARS Stat AP Server to Bars Stat DB"
      source_security_group_id = dependency.sg_ap.outputs.security_group_id
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
