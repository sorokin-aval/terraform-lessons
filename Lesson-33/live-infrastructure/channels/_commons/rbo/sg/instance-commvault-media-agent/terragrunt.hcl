dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LRAInstanceCommVaultMediaAgent"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the CommVault Media Agent instance"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from private Support IP pool"
      cidr_blocks = local.account_vars.support_access_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Access from Zabbix server"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "Zabbix Ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Allow ICMP"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "CommVault Backup in Tier2"
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      description = "Access for CommVault Backup in Tier2"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "CommVault Backup in Tier3"
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      description = "Access for CommVault Backup in Tier3"
      cidr_blocks = local.account_vars.tier3_subnets
    },
    {
      name        = "CommVault Backup Control Server"
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      description = "Access for CommVault Backup Control Server"
      cidr_blocks = local.account_vars.commvault_control_subnets
    },
  ],
  egress_with_cidr_blocks = [
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Access to Zabbix server"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to Active Directory Cloud"
      cidr_blocks = local.account_vars.auth_subnets
    },
    {
      name        = "AD - Kerberos TCP"
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Access to Active Directory - Kerberos TCP"
      cidr_blocks = local.account_vars.auth_subnets
    },
    {
      name        = "AD - Kerberos UDP"
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Access to Active Directory - Kerberos UDP"
      cidr_blocks = local.account_vars.auth_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Access to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
    {
      name        = "CommVault backup agents on DB servers in Tier2"
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      description = "Access for CommVault backup agents on DB servers in Tier2"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "CommVault backup agents on DB servers in Tier3"
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      description = "Access for CommVault backup agents on DB servers in Tier3"
      cidr_blocks = local.account_vars.tier3_subnets
    },
    {
      name        = "S3"  # TODO: consider private endpoint implementation
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS for S3"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "CommVault Backup Control Server"
      from_port   = 8400
      to_port     = 8403
      protocol    = "tcp"
      description = "Access for CommVault Backup Control Server"
      cidr_blocks = local.account_vars.commvault_control_subnets
    },
  ],
}
