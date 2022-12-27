include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_nacl
}

locals {
  name         = "NACL-RBUA-${local.account_vars.environment_letter}-${local.account_vars.tier1_subnet_abbr}"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "NACL for the Tier1 subnets"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map
  subnet_ids  = dependency.vpc.outputs.lb_subnets.ids


  ############## Inbound ##############

  inbound_acl_rules = concat(
    # Allow inbound App access from anywhere (restrict only in SG)
    [ 
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8084
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows inbound SSH traffic from Support private subnets
    [ for i, subnet in local.account_vars.support_access_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound Zabbix-agent port 10050 from common infrastructure subnets
    [ for i, subnet in local.account_vars.zabbix_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 10050
        to_port     = 10050
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound Zabbix-agent port 10050 from common infrastructure subnets
    [ for i, subnet in local.account_vars.zabbix_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 10051
        to_port     = 10051
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound return traffic(that is, for requests that originate in the subnet).
    [
      {
        rule_number = 500
        rule_action = "allow"
        from_port   = 49152
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allow inbound HTTPS access from anywhere
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

    # Allow inbound HTTPS access from account subnets
    [ for i, subnet in local.account_vars.account_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound tcp access from account public subnets
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound tcp access from AWS AD subnets
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 900 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound tcp access from RBUA private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 1000 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound tcp traffic from RBUA AWS subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound access from Logstash subnets
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

    # Allows inbound app traffic.
    [ 
      {
        rule_number = 1400
        rule_action = "allow"
        from_port   = 9000
        to_port     = 9000
        protocol    = "tcp"
        cidr_block  = "10.0.0.0/8"
      }
    ],

    # Allows inbound traffic from outside
    [ 
      {
        rule_number = 1500
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],
  )


  ############## Outbound ##############

  outbound_acl_rules = concat(
    # Allows outbound connections to database
    [ for i, subnet in local.account_vars.db_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 4100
        to_port     = 4100
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound HTTPS responses to account private subnets
    [ for i, subnet in local.account_vars.account_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound HTTPS
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

    # Allows LDAP access to AWS LDAP private subnets
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 636
        to_port     = 636
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound app access.
    [
      {
        rule_number = 600
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8080
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

    # Allows outbound access to Active Directory Cloud subnets for Kerberos auth
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud subnets for Kerberos auth
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 900 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "udp"
        cidr_block  = subnet
      }
    ],
    # Allows outbound response to RBUA on-premise private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 1000 + i
        rule_action = "allow"
        from_port   = 49152
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to infra subnets for Zabbix, infra resources etc.
    [ for i, subnet in local.account_vars.infra_subnets_list :
      {
        rule_number = 1100 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to account public subnets
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to account private subnets
    [ for i, subnet in local.account_vars.account_subnets_list :
      {
        rule_number = 1300 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to public subnets
    [ for i, subnet in local.account_vars.cloud_flare_subnets_list :
      {
        rule_number = 1400 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound Logstash access to tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 1500 + i
        rule_action = "allow"
        from_port   = 5044
        to_port     = 5044
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound HTTPS
    [ 
      {
        rule_number = 1600
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],
  )
}
