dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LRAInstanceDB"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the DB instance"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = concat(
    [
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
        to_port     = 1522
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
        to_port     = 1522
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
        to_port     = 1522
        protocol    = "tcp"
        description = "Access from support subnets"
        cidr_blocks = local.account_vars.support_access_subnets
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
        to_port     = 1522
        protocol    = "tcp"
        description = "Access from Common Infra subnets"
        cidr_blocks = local.account_vars.common_infra_subnets
      },
      {
        name        = "From IBM MQ IP pool SSL"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = "Access from IBM MQ IP pool SSL"
        cidr_blocks = local.account_vars.ibm_mq_subnets
      },
      {
        name        = "From IBM MQ IP pool"
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        description = "Access from IBM MQ IP pool"
        cidr_blocks = local.account_vars.ibm_mq_subnets
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
        name        = "From on-premise private subnets"
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        description = "Allow from on-premise private subnets"
        cidr_blocks = local.account_vars.rbua_private_subnets
      },
      {
        name        = "From on-premise private subnets"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = "Allow from on-premise private subnets"
        cidr_blocks = local.account_vars.rbua_private_subnets
      },
      {
        name        = "From celer.cbs.rbua subnets"
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        description = "Allow from celer.cbs.rbua AWS private subnets"
        cidr_blocks = local.account_vars.celer_cbs_subnets
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
    ],
    [ for subnet in local.account_vars.inbound_db_oracle_backup_subnets_list :
      {
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [ for subnet in local.account_vars.inbound_db_oracle_backup_subnets_list :
      {
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [ for subnet in local.account_vars.inbound_db_oracle_backup_subnets_list :
      {
        from_port   = 8400
        to_port     = 8403
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [ for subnet in local.account_vars.inbound_db_oracle_backup_subnets_list :
      {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [ for subnet in local.account_vars.inbound_db_oracle_subnets_list :
      {
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [ for subnet in local.account_vars.inbound_db_oracle_subnets_list :
      {
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [
      {
        name        = "From Tier3 SSL"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = "Access from tier3 subnets"
        cidr_blocks = local.account_vars.tier3_subnets
      },
      {
        name        = "From Tier3"
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        description = "Access from tier3 subnets"
        cidr_blocks = local.account_vars.tier3_subnets
      },
    ]
  )
  egress_with_cidr_blocks = concat(
    [
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
        name        = "CommVault Backup Control Server"
        from_port   = 8400
        to_port     = 8403
        protocol    = "tcp"
        description = "Access for CommVault Backup Control Server"
        cidr_blocks = local.account_vars.commvault_control_subnets
      },
      {
        name        = "Syslog servers"
        from_port   = 514
        to_port     = 514
        protocol    = "udp"
        description = "Access to Syslog servers"
        cidr_blocks = local.account_vars.syslog_servers_subnets
      },
    ],
    [ for subnet in local.account_vars.outbound_db_oracle_sync_subnets_list :
      {
        from_port   = 1521
        to_port     = 1521
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [ for subnet in local.account_vars.outbound_db_oracle_sync_subnets_list :
      {
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
    [
      {
        name        = "To Tier2 SSL"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = "Access to tier2 subnets"
        cidr_blocks = local.account_vars.tier2_subnets
      },
      {
        name        = "To Tier2"
        from_port   = 1521
        to_port     = 1521
        protocol    = "tcp"
        description = "Access to tier2 subnets"
        cidr_blocks = local.account_vars.tier2_subnets
      },
      {
        name        = "To Tier3 SSL"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        description = "Access to tier3 subnets"
        cidr_blocks = local.account_vars.tier3_subnets
      },
      {
        name        = "To Tier3"
        from_port   = 1521
        to_port     = 1521
        protocol    = "tcp"
        description = "Access to tier3 subnets"
        cidr_blocks = local.account_vars.tier3_subnets
      },
    ]
  )
}
