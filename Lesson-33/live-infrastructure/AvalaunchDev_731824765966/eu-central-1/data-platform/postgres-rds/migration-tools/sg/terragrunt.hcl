# Hardcode!
dependency "vpc" {
  config_path = "../../../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-postgres-sg"
}

inputs = {
  name               = local.name
  description        = "Security group for ${local.name}"
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  tags               = local.tags_map

  ingress_cidr_blocks      = ["${dependency.vpc.outputs.vpc_id.cidr_block}"]
  ingress_with_cidr_blocks = [
    {
      name        = "postgres"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "postgres"
      cidr_blocks = "${dependency.vpc.outputs.vpc_id.cidr_block}"
    },
    {
      name        = "VPN POOL"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "developers-vpn-pool"
      cidr_blocks = "10.190.247.0/24"
    },
    {
      name        = "AD service"
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "shared AD service"
      cidr_blocks = "10.225.109.59/32"
    },
    {
      name        = "HO-POOL-BI"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "ho BI pool"
      cidr_blocks = "10.190.125.128/25"
    },
    {
      name        = "Pool VDI"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "VDI poll"
      cidr_blocks = "10.190.49.0/26"
    }
  ]

  /* ingress_with_source_security_group_id     = [
    {
      name                      = "sg-067c4c76471713085"
      source_security_group_id  = "sg-067c4c76471713085"
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      description               = "sg-067c4c76471713085"
    },
    {
      name                      = "sg-0398fcc0571614bfc"
      source_security_group_id  = "sg-0398fcc0571614bfc"
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      description               = "sg-0398fcc0571614bfc"
    },
    {
      name                      = "sg-04016db5270ac50ff"
      source_security_group_id  = "sg-04016db5270ac50ff"
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      description               = "sg-04016db5270ac50ff"
    },
    {
      name                      = "sg-058a528809b3221c5"
      source_security_group_id  = "sg-058a528809b3221c5"
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      description               = "sg-058a528809b3221c5"
    },
    {
      name                      = "sg-0ab1422c53b323831"
      source_security_group_id  = "sg-0ab1422c53b323831"
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      description               = "sg-0ab1422c53b323831"
    },
    {
      name                      = "sg-064f7fa4426337b5b"
      source_security_group_id  = "sg-064f7fa4426337b5b"
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      description               = "sg-064f7fa4426337b5b"
    }
  ] */

  egress_with_cidr_blocks = [
        {
      name = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}