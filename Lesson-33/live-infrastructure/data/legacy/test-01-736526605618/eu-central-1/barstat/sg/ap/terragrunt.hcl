include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

# Hardcode!
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
  name         = "${local.tags_map.Project}-${local.tags_map.Environment}"
}

inputs = {
  name        = local.name
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      description = "HTTP access from VDI Pool HO-DIR"
      cidr_blocks = "10.190.40.0/21"
    },
    {
      rule        = "https-443-tcp"
      description = "HTTPS access from VDI Pool HO-DIR"
      cidr_blocks = "10.190.40.0/21"
    },
    {
      rule        = "rdp-tcp"
      description = "RDP access from CyberArk"
      cidr_blocks = "10.191.242.32/28"
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
