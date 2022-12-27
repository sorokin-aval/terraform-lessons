include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-WindowsDependencies"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for Windows-based instances"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = []
  egress_with_cidr_blocks = [
    {
      name        = "AD"
      from_port   = 389
      to_port     = 389
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 464
      to_port     = 464
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 464
      to_port     = 464
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 9389
      to_port     = 9389
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 137
      to_port     = 138
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 5722
      to_port     = 5722
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 139
      to_port     = 139
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 1688
      to_port     = 1688
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 3268
      to_port     = 3269
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 49152
      to_port     = 65535
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 135
      to_port     = 135
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 123
      to_port     = 123
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD"
      from_port   = 123
      to_port     = 123
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "AD ICMP"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_subnets
    },
    {
      name        = "UpdateServer"
      from_port   = 8530
      to_port     = 8530
      protocol    = "tcp"
      description = "Access to RBUA internal update server"
      cidr_blocks = local.account_vars.wininfra_subnets
    },
    {
      name        = "SMB"
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "Access to awsec2-wfile01.ms.aval"
      cidr_blocks = local.account_vars.awsec2_wfile01_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Allow connections to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
  ]
}
