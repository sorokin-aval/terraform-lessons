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
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.project_vars.locals.resource_prefix}"
}

inputs = {
  name                     = local.name
  description              = "Security group for ${local.name}"
  vpc_id                   = dependency.vpc.outputs.vpc_id.id
  tags                     = local.tags_map
  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      description = "DEV VPN POOL"
      cidr_blocks = "10.190.247.0/24"
    },
    {
      rule        = "postgresql-tcp"
      description = "access form zuko"
      cidr_blocks = "10.191.4.155/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "Access for Superset OnPrem(presto.app.kv.aval)"
      cidr_blocks = "10.191.4.29/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "VDI for Datastage & MBrocker admins"
      cidr_blocks = "10.190.49.0/26"
    },
    {
      rule        = "postgresql-tcp"
      description = "o365gateway1.azure.aval"
      cidr_blocks = "10.191.1.3/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "o365gateway2.azure.aval"
      cidr_blocks = "10.191.1.4/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "o365gateway3.azure.aval"
      cidr_blocks = "10.191.1.5/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "o365gateway4.azure.aval"
      cidr_blocks = "10.191.1.6/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "jasperrep.app.kv.aval"
      cidr_blocks = "10.191.4.30/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "datacatalog.rbigroup.cloud"
      cidr_blocks = "10.223.39.132/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "nifi-01.data.rbua"
      cidr_blocks = "10.225.126.47/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "nifi-02.data.rbua"
      cidr_blocks = "10.225.125.250/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "nifi-03.data.rbua"
      cidr_blocks = "10.225.125.79/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "EKS node B"
      cidr_blocks = "10.225.125.228/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "EKS node A"
      cidr_blocks = "10.225.125.125/32"
    },
    {
      rule        = "postgresql-tcp"
      description = "EKS node C"
      cidr_blocks = "10.225.126.117/32"
    },

  ]
  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = "sg-072933c9b59b99330"
    },
    {
      rule                     = "postgresql-tcp"
      description              = "access from terraform"
      source_security_group_id = "sg-0bf595b6b3c47f09b"
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
