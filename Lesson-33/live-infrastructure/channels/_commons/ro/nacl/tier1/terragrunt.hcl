dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_nacl
}

locals {
  name         = "NACL-RBUA-${local.account_vars.environment_letter}-${local.account_vars.tier1_subnet_abbr}-001"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "NACL for the Tier1 subnets"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map
  subnet_ids  = dependency.vpc.outputs.lb_subnets.ids


  ############## Inbound ##############

  inbound_acl_rules = concat(
    # Allow inbound App access from Tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = local.app_port
        to_port     = local.app_port
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound App access from Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = local.app_port
        to_port     = local.app_port
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound SSH traffic from Support private subnets
    [ for i, subnet in local.account_vars.support_access_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

#    # Allows inbound Zabbix-agent port 10050 from common infrastructure subnets
#    [ for i, subnet in local.account_vars.common_infra_subnets_list :
#      {
#        rule_number = 400 + i
#        rule_action = "allow"
#        from_port   = 10050
#        to_port     = 10050
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],

    # Allows ICMP from common infrastructure subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        icmp_type   = -1
        icmp_code   = -1
        protocol    = "icmp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet).
    [
      {
        rule_number = 600
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allow inbound HTTPS access from Tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound HTTPS access from Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

#    # Allow inbound app access from Tier1 subnets on alt port
#    [ for i, subnet in local.account_vars.tier1_subnets_list :
#      {
#        rule_number = 900 + i
#        rule_action = "allow"
#        from_port   = 9443
#        to_port     = 9443
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allow inbound app access from Tier2 subnets on alt port
#    [ for i, subnet in local.account_vars.tier2_subnets_list :
#      {
#        rule_number = 1000 + i
#        rule_action = "allow"
#        from_port   = 9443
#        to_port     = 9443
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],

    # Allows inbound HTTPS traffic to public subnet.
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 1100 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound HTTPS traffic from RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

#    # Allows inbound access from Logstash subnets
#    [ for i, subnet in local.account_vars.logstash_subnets_list :
#      {
#        rule_number = 1300 + i
#        rule_action = "allow"
#        from_port   = 5044
#        to_port     = 5044
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound Logstash access from tier1 subnets
#    [ for i, subnet in local.account_vars.tier1_subnets_list :
#      {
#        rule_number = 1400 + i
#        rule_action = "allow"
#        from_port   = 5044
#        to_port     = 5044
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound DB traffic.
#    [ for i, subnet in local.account_vars.inbound_db_subnets_list :
#      {
#        rule_number = 1500 + i
#        rule_action = "allow"
#        from_port   = 1575
#        to_port     = 1575
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound DB traffic.
#    [ for i, subnet in local.account_vars.inbound_db_subnets_list :
#      {
#        rule_number = 1600 + i
#        rule_action = "allow"
#        from_port   = 1521
#        to_port     = 1521
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound OracleSQL traffic from Support private subnets
#    [ for i, subnet in local.account_vars.support_access_subnets_list :
#      {
#        rule_number = 1700 + i
#        rule_action = "allow"
#        from_port   = 1521
#        to_port     = 1521
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound OracleSQL traffic from IBM MQ private subnets
#    [ for i, subnet in local.account_vars.ibm_mq_subnets_list :
#      {
#        rule_number = 1800 + i
#        rule_action = "allow"
#        from_port   = 1521
#        to_port     = 1521
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound OracleSQL traffic from Common Infra private subnets
#    [ for i, subnet in local.account_vars.common_infra_subnets_list :
#      {
#        rule_number = 1900 + i
#        rule_action = "allow"
#        from_port   = 1521
#        to_port     = 1521
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],
#
#    # Allows inbound OracleSQL traffic from Common Infra private subnets
#    [ for i, subnet in local.account_vars.common_infra_subnets_list :
#      {
#        rule_number = 2000 + i
#        rule_action = "allow"
#        from_port   = 1521
#        to_port     = 1521
#        protocol    = "tcp"
#        cidr_block  = subnet
#      }
#    ],

    # Allow inbound HTTPS access from IBM MQ subnets
    [ for i, subnet in local.account_vars.ibm_mq_subnets_list :
      {
        rule_number = 2100 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],


    # Allow inbound SSH access from Bastion host
    [ 
      {
        rule_number = 2200
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "${local.account_vars.bastion_host_ip}/32"
      }
    ],
  )


  ############## Outbound ##############

  outbound_acl_rules = concat(
    # Allows outbound responses to clients in Tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound responses to clients in Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound return traffic to RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound Zabbix-agent on port 10051 in common infrastructure subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 10051
        to_port     = 10051
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows ICMP responses to common infrastructure subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        icmp_type   = -1
        icmp_code   = -1
        protocol    = "icmp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound HTTPS to AppDynamics, etc.
    [
      {
        rule_number = 600
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound access to Logstash subnets
    [ for i, subnet in local.account_vars.logstash_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Oracle DB subnets
    [ for i, subnet in local.account_vars.db_subnets_list :
      {
        rule_number = 900 + i
        rule_action = "allow"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to IBM Message Broker
    [ for i, subnet in local.account_vars.ibm_mq_subnets_list :
      {
        rule_number = 1000 + i
        rule_action = "allow"
        from_port   = 1415
        to_port     = 1415
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 1100 + i
        rule_action = "allow"
        from_port   = 636
        to_port     = 636
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory On-Premise
    [ for i, subnet in local.account_vars.ad_onprem_subnets_list :
      {
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 636
        to_port     = 636
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Apple Cloud Push notifications
    [
      {
        rule_number = 1300
        rule_action = "allow"
        from_port   = 2195
        to_port     = 2196
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound traffic to public subnet.
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 1700 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to TSP over HTTP
    [
      {
        rule_number = 1800
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound access to TSP over HTTP - Treasury
    [
      {
        rule_number = 1900
        rule_action = "allow"
        from_port   = 43221
        to_port     = 43221
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound access to McAfee Web Gateway ICAP
    [ for i, subnet in local.account_vars.security_subnets_list :
      {
        rule_number = 2000 + i
        rule_action = "allow"
        from_port   = 1344
        to_port     = 1344
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound traffic to ActiveMQ subnets.
    [ for i, subnet in local.account_vars.activemq_subnets_list :
      {
        rule_number = 2100 + i
        rule_action = "allow"
        from_port   = 61616
        to_port     = 61616
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound Logstash access to tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 2200 + i
        rule_action = "allow"
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud - Kerberos TCP
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 2300 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud - Kerberos UDP
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 2400 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "udp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to RBUA Private AWS subnets.
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 2500 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to DB inbound subnets.
    [ for i, subnet in local.account_vars.inbound_db_subnets_list :
      {
        rule_number = 2700 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  )
}
