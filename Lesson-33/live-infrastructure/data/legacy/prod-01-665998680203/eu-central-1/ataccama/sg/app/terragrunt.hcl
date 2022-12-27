include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "ataccama_alb_sg_id" {
  config_path = "../alb/"
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
  name       = "${local.tags_map.Name}-${local.tags_map.Environment}-${local.tags_map.Project}"
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
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "https-443-tcp"
      description              = "HTTP access from ALB"
      source_security_group_id = dependency.ataccama_alb_sg_id.outputs.security_group_id
    },
    {
      rule                     = "https-8443-tcp"
      description              = "HTTPS access from ALB"
      source_security_group_id = dependency.ataccama_alb_sg_id.outputs.security_group_id
    },
    {
      from_port                = 8777
      to_port                  = 8777
      protocol                 = 6
      description              = "HTTPS access from ALB"
      source_security_group_id = dependency.ataccama_alb_sg_id.outputs.security_group_id
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
