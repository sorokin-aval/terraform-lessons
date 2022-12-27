include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "sota_app_sg_id" {
  config_path = "../app/"
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
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map   = merge(local.project_vars.locals.project_tags, { Name = "legacy" })
  name       = "${local.tags_map.Name}-${local.tags_map.Environment}-${local.tags_map.Project}-${basename(get_terragrunt_dir())}"
}

inputs = {
  name        = local.name
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_self = [
    {
      rule        = "ssh-tcp"
      description = "SSH access with SELF"
      self        = true
    },
    {
      rule        = "mysql-tcp"
      description = "Access to MySQL/Aurora with SELF"
      self        = true
    }
  ]

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      description = "SSH access from CyberArk"
      cidr_blocks = "10.191.242.32/28"
    },
    {
      rule        = "ssh-tcp"
      description = "SSH access from HO-POOL-DBA"
      cidr_blocks = "10.190.62.128/26"
    },
    {
      rule        = "ssh-tcp"
      description = "SSH access from Linux Admins server"
      cidr_blocks = "10.225.112.126/32"
    },
    {
      rule        = "mysql-tcp"
      description = "Access to MySQL/Aurora from from CyberArk"
      cidr_blocks = "10.191.242.32/28"
    },
    {
      rule        = "mysql-tcp"
      description = "Access to MySQL/Aurora from HO-POOL-DBA"
      cidr_blocks = "10.190.62.128/26"
    },
    {
      rule        = "mysql-tcp"
      description = "Access to MySQL/Aurora from VDI Nets"
      cidr_blocks = "10.190.131.0/26"
    },
    {
      rule        = "mysql-tcp"
      description = "Access to MySQL/Aurora from Actieve on-prem DB sotadb1.mydb.kv.aval"
      cidr_blocks = "10.191.15.20/32"
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      description              = "Access to MySQL/Aurora from sota-app01/02"
      source_security_group_id = dependency.sota_app_sg_id.outputs.security_group_id
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
