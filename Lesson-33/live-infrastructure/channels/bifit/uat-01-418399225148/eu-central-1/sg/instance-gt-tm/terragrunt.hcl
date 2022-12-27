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
  name         = "SG-RBUA-InstanceGTTM"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for Gateway TM instance"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "Zabbix"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Access to application from Zabbix servers"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Access to application from Zabbix servers"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "RDP"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Access from support private pool"
      cidr_blocks = local.account_vars.support_access_subnets
    },
  ]
  egress_with_cidr_blocks = [
    {
      name        = "DBs"
      from_port   = 4100
      to_port     = 4100
      protocol    = "tcp"
      description = "Access to databases"
      cidr_blocks = local.account_vars.db_subnets
    },
    {
      name        = "Archive DB"
      from_port   = 4300
      to_port     = 4300
      protocol    = "tcp"
      description = "Access to archive databas"
      cidr_blocks = local.account_vars.db_subnets
    },
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
      name        = "App"
      from_port   = 8080
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to applications from account private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "RPC"
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "RPC ports for RDP to support private pool"
      cidr_blocks = local.account_vars.support_access_subnets
    },
    {
      name        = "RPC"
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "RPC ports for private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "File Share"
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "Access to file shares"
      cidr_blocks = local.account_vars.fs_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS access for SSM"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "Access to Zabbix servers"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "Transmaster Ports"
      from_port   = 15203
      to_port     = 15203
      protocol    = "tcp"
      description = "Access to DB Transmaster without SSL"
      cidr_blocks = local.account_vars.db_tm_subnets
    },
    {
      name        = "Transmaster Ports"
      from_port   = 15703
      to_port     = 15703
      protocol    = "tcp"
      description = "Access to DB Transmaster with SSL"
      cidr_blocks = local.account_vars.db_tm_subnets
    },
    {
      name        = "IBM Ports"
      from_port   = 1415
      to_port     = 1415
      protocol    = "tcp"
      description = "Access to IBM Message Broker"
      cidr_blocks = local.account_vars.ibm_subnets
    },
  ]
}
