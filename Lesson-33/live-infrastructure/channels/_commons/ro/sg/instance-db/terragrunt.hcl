dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIAInstanceDB"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for the DB instance"
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
      name        = "From Tier1 SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access from tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "From Tier1"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access from tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "From Tier2 SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access from tier2 subnets"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "From Tier2"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access from tier2 subnets"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "From Support IP pool SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access from support subnets"
      cidr_blocks = local.account_vars.support_access_subnets
    },
    {
      name        = "From Support IP pool"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access from support subnets"
      cidr_blocks = local.account_vars.support_access_subnets
    },
    {
      name        = "From IBM MQ IP pool SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access from support subnets"
      cidr_blocks = local.account_vars.ibm_mq_subnets
    },
    {
      name        = "From IBM MQ IP pool"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access from support subnets"
      cidr_blocks = local.account_vars.ibm_mq_subnets
    },
    {
      name        = "Inbound DB SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access from specified subnets"
      cidr_blocks = local.account_vars.inbound_db_subnets
    },
    {
      name        = "Inbound DB"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access from specified subnets"
      cidr_blocks = local.account_vars.inbound_db_subnets
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
  ]
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
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Access to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Access to Logstash LB"
      cidr_blocks = local.account_vars.tier1_subnets
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
      name        = "From Common Infra IP pool SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access from Common Infra subnets"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "From Common Infra IP pool"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access from Common Infra subnets"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
  ]
}
