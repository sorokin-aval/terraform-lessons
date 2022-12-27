dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

terraform { source = local.account_vars.sources_nacl }

locals {
  name         = "NACL-RBUA-${local.account_vars.environment_letter}-${local.account_vars.tier3_subnet_abbr}-001"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = merge(local.tags_map, { Name = local.name })
  subnet_ids  = dependency.vpc.outputs.db_subnets.ids


  ############## Inbound ##############

  inbound_acl_rules = concat(
    # Allows inbound SSH traffic from Support private subnets
    [ for i, subnet in local.account_vars.support_access_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows ICMP from common infrastructure subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        icmp_type   = -1
        icmp_code   = -1
        protocol    = "icmp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound Postgres RDS from RBUA private AWS subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound OracleSQL from RBUA private AWS subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound OracleSQL SSL from RBUA private AWS subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound Postgres RDS from RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound OracleSQL from RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 1521
        to_port     = 1522
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound OracleSQL SSL from RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound Zabbix
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 900 + i
        rule_action = "allow"
        from_port   = 10050
        to_port     = 10050
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound Backup
    [ for i, subnet in local.account_vars.commvault_control_subnets_list :
      {
        rule_number = 1000 + i
        rule_action = "allow"
        from_port   = 8400
        to_port     = 8403
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from common Infra subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 1100 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from Auth subnets
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from Logstash subnets
    [ for i, subnet in local.account_vars.logstash_subnets_list :
      {
        rule_number = 1300 + i
        rule_action = "allow"
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 1400 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from Tier3 subnets
    [ for i, subnet in local.account_vars.tier3_subnets_list :
      {
        rule_number = 1500 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from CommVault subnets
    [ for i, subnet in local.account_vars.commvault_control_subnets_list :
      {
        rule_number = 1600 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet) - from Oracle Sync subnets
    [ for i, subnet in local.account_vars.outbound_db_oracle_sync_subnets_list :
      {
        rule_number = 1700 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet.cidr
      }
    ],
  )


  ############## Outbound ##############

  outbound_acl_rules = concat(
    # Allows outbound responses to clients in RBUA private AWS subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound responses to clients in RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound to Active Directory Cloud
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 636
        to_port     = 636
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound to Active Directory Cloud - Kerberos TCP
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound to Active Directory Cloud - Kerberos UDP
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "udp"
        cidr_block  = subnet
      }
    ],

    # Allows ICMP responses to common infrastructure subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        icmp_type   = -1
        icmp_code   = -1
        protocol    = "icmp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Syslog servers
    [ for i, subnet in local.account_vars.syslog_servers_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 514
        to_port     = 514
        protocol    = "udp"
        cidr_block  = subnet
      }
    ],
  )
}
