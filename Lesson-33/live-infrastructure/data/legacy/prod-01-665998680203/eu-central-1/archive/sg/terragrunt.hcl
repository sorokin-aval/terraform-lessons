include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

# Hardcode!
dependency "vpc" {
  config_path = "../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.16.2"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.tags_map.Name}-${local.tags_map.Environment}"
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
      description = "JumpHost for SSH Linux&DevOps team"
      cidr_blocks = "10.225.112.126/32"
    },
    {
      rule        = "https-443-tcp"
      description = "HTTPS access from on-premise VDI Pool"
      cidr_blocks = "10.190.56.0/22"
    },
    {
      rule        = "https-443-tcp"
      description = "HTTPS access from on-premise VDI Pool"
      cidr_blocks = "10.190.114.0/23"
    },
    {
      rule        = "https-443-tcp"
      description = "HTTPS access from on-premise VDI Pool"
      cidr_blocks = "10.191.242.0/24"
    },   
    {
      rule        = "http-80-tcp"
      description = "HTTP access from on-premise VDI Pool"
      cidr_blocks = "10.190.56.0/22"
    },
    {
      rule        = "http-80-tcp"
      description = "HTTP access from on-premise VDI Pool"
      cidr_blocks = "10.190.114.0/23"
    },
    {
      rule        = "http-80-tcp"
      description = "HTTP access from on-premise VDI Pool"
      cidr_blocks = "10.191.242.0/24"
    },
    {
      rule        = "https-443-tcp"
      description = "HTTPS access from VDI Pool HO-DIR"
      cidr_blocks = "10.190.40.0/21"
    },
    {
      rule        = "http-80-tcp"
      description = "HTTP access from VDI Pool HO-DIR"
      cidr_blocks = "10.190.40.0/21"
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
