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
  name         = "NACL-RBUA-${local.account_vars.environment_letter}-${local.account_vars.tier2_subnet_abbr}"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "NACL for the Tier2 subnets"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map
  subnet_ids  = dependency.vpc.outputs.app_subnets.ids


  ############## Inbound ##############

  inbound_acl_rules = concat(
    # Allow inbound tcp access from account private subnets
    [ for i, subnet in local.account_vars.account_subnets_list :
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound RDP traffic from support private subnets
    [ for i, subnet in local.account_vars.support_access_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 3389
        to_port     = 3389
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

    # Allows inbound tcp traffic from RBUA AWS private subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound tcp access from RBUA on-premise private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allow inbound tcp access from Active Directory on-premise
    [ for i, subnet in local.account_vars.ad_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = subnet
      }
    ],

    # Allows inbound access to applications from public balancer
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8084
        protocol    = "tcp"
        cidr_block  = subnet
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

    # Allows outbound HTTPS
    [ 
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows all traffic to Active Directory on-premise
    [ for i, subnet in local.account_vars.ad_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to applications inside the account
    [ for i, subnet in local.account_vars.account_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 8080
        to_port     = 8084
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to file shares
    [ for i, subnet in local.account_vars.fs_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 445
        to_port     = 445
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
    # Allows all traffic to RBUA on-premise private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = subnet
      }
    ],

    # Allows outbound response to Zabbix subnets.
    [ for i, subnet in local.account_vars.zabbix_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound response traffic to account private subnets
    [ for i, subnet in local.account_vars.account_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound tcp access to RBUA AWS private subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 900 + i
        rule_action = "allow"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound tcp access to RBUA AWS private subnets
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

    # Allows outbound HTTPS
    [ 
      {
        rule_number = 1100
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],
  )
}
