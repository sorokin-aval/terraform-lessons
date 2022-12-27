include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "vpc" {
  config_path = "../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.13.1"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  # Extract out exact variables for reuse
  tags_map = merge(local.project_vars.locals.project_tags, { Name = "legacy" })
  name     = "${local.tags_map.Name}-${local.tags_map.Environment}-${local.tags_map.Project}-${basename(get_terragrunt_dir())}"
}

inputs = {
  name        = local.name
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      rule        = "rdp-tcp"
      description = "RDP access from CyberArk"
      cidr_blocks = "10.191.242.32/28"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI Pool HO-DIR to Remote Procedure Call"
      cidr_blocks = "10.190.40.0/21"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI Pool Kherson OC to Remote Procedure Call"
      cidr_blocks = "10.190.56.0/22"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI Pool Kherson OC DNV to Remote Procedure Call"
      cidr_blocks = "10.190.114.0/23"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI Pool to Remote Procedure Call"
      cidr_blocks = "10.190.0.0/19"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI Pool to Remote Procedure Call"
      cidr_blocks = "10.190.32.0/21"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI Pool for ETL & ESB admins to Remote Procedure Call"
      cidr_blocks = "10.190.49.0/26"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from VDI for BI to Remote Procedure Call"
      cidr_blocks = "10.190.125.128/25"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from RBUA-VDI-TVBV to Remote Procedure Call"
      cidr_blocks = "10.226.48.0/20"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from Accounting Workstaion uadho-d10-bars to Remote Procedure Call"
      cidr_blocks = "10.191.135.91/32"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = 6
      description = "Access from Accounting Workstaion uadho-w10-bars to Remote Procedure Call"
      cidr_blocks = "10.191.135.87/32"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI Pool HO-DIR to Windows Share (tls smb)"
      cidr_blocks = "10.190.40.0/21"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI Pool Kherson OC to Windows Share (tls smb)"
      cidr_blocks = "10.190.56.0/22"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI Pool Kherson OC DNV to Windows Share (tls smb)"
      cidr_blocks = "10.190.114.0/23"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI Pool to Windows Share (tls smb)"
      cidr_blocks = "10.190.0.0/19"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI Pool to Windows Share (tls smb)"
      cidr_blocks = "10.190.32.0/21"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI Pool for ETL & ESB admins to Windows Share (tls smb)"
      cidr_blocks = "10.190.49.0/26"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from VDI for BI to Windows Share (tls smb)"
      cidr_blocks = "10.190.125.128/25"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from RBUA-VDI-TVBV to Windows Share (tls smb)"
      cidr_blocks = "10.226.48.0/20"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from Accounting Workstaion uadho-d10-bars to Windows Share (tls smb)"
      cidr_blocks = "10.191.135.91/32"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = 6
      description = "Access from Accounting Workstaion uadho-w10-bars to Windows Share (tls smb)"
      cidr_blocks = "10.191.135.87/32"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI Pool HO-DIR to Vicont aplication"
      cidr_blocks = "10.190.40.0/21"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI Pool Kherson OC to Vicont aplication"
      cidr_blocks = "10.190.56.0/22"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI Pool Kherson OC DNV to Vicont aplication"
      cidr_blocks = "10.190.114.0/23"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI Pool to Vicont aplication"
      cidr_blocks = "10.190.0.0/19"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI Pool to Vicont aplication"
      cidr_blocks = "10.190.32.0/21"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI Pool for ETL & ESB admins to Vicont aplication"
      cidr_blocks = "10.190.49.0/26"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from VDI for BI to Vicont aplication"
      cidr_blocks = "10.190.125.128/25"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from RBUA-VDI-TVBV to Vicont aplication"
      cidr_blocks = "10.226.48.0/20"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from Accounting Workstaion uadho-d10-bars to  Vicont aplication"
      cidr_blocks = "10.191.135.91/32"
    },
    {
      from_port   = 5000
      to_port     = 5100
      protocol    = 6
      description = "Access from Accounting Workstaion uadho-w10-bars to  Vicont aplication"
      cidr_blocks = "10.191.135.87/32"
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
