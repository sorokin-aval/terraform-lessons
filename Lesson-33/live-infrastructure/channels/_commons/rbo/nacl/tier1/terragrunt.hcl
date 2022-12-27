dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

terraform { source = local.account_vars.sources_nacl }

locals {
  name         = "NACL-RBUA-${local.account_vars.environment_letter}-${local.account_vars.tier1_subnet_abbr}-001"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = merge(local.tags_map, { Name = local.name })
  subnet_ids  = dependency.vpc.outputs.lb_subnets.ids


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

    # Allows inbound return traffic(that is, for requests that originate in the subnet).
    [
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows inbound HTTPS traffic from public subnet.
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = local.app_port
        to_port     = local.app_port
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound SSH access from Bastion host
    [ 
      {
        rule_number = 500
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
    # Allows access to IS-Front in Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 8443
        to_port     = 8443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound Zabbix-agent on port 10051 in common infrastructure subnets
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 200 + i
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
        rule_number = 300 + i
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
        rule_number = 400
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound access to OracleDB NLB in the Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 1521
        to_port     = 1521
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to OracleDB SSL NLB in the Tier2 subnets
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 1575
        to_port     = 1575
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 700 + i
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
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 636
        to_port     = 636
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound traffic to public subnet.
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 900 + i
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
        rule_number = 1000
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound access to McAfee Web Gateway ICAP
    [ for i, subnet in local.account_vars.security_subnets_list :
      {
        rule_number = 1100 + i
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
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 61616
        to_port     = 61616
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud - Kerberos TCP
    [ for i, subnet in local.account_vars.auth_subnets_list :
      {
        rule_number = 1300 + i
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
        rule_number = 1400 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "udp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to support subnets.
    [ for i, subnet in local.account_vars.support_access_subnets_list :
      {
        rule_number = 1500 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to common infra subnets.
    [ for i, subnet in local.account_vars.common_infra_subnets_list :
      {
        rule_number = 1600 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Internal CSK Backend
    [ for i, subnet in local.account_vars.security_subnets_list :
      {
        rule_number = 1700 + i
        rule_action = "allow"
        from_port   = 8082
        to_port     = 8082
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Logstash
    [ for i, subnet in local.account_vars.logstash_subnets_list :
      {
        rule_number = 1800 + i
        rule_action = "allow"
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to Tier2 subnets.
    [ for i, subnet in local.account_vars.tier2_subnets_list :
      {
        rule_number = 1900 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to support subnets.
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 2200 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  )
}
