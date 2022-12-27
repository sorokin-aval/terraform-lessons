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
  subnet_ids  = dependency.vpc.outputs.db_subnets.ids


  ############## Inbound ##############

  inbound_acl_rules = concat(
    # Allows inbound traffic to Redis from Tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound traffic to RDS PostgreSQL from tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound traffic to RDS PostgreSQL from IDM MQ subnets
    [ for i, subnet in local.account_vars.ibm_mq_subnets_list :
      {
        rule_number = 300 + i
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound traffic to RDS PostgreSQL from RBUA on-premise private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound traffic to RDS MariaDB from tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound traffic to RDS MariaDB from Salesbasesubnets
    [ for i, subnet in local.account_vars.salesbase_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
      
      # Allows inbound traffic to RDS MariaDB from RBUA on-premise private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

      # Allows inbound traffic to RDS MariaDB from Salesbase AWS private subnets
    [ for i, subnet in local.account_vars.salesbase_aws_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  )


  ############## Outbound ##############

  outbound_acl_rules = concat(
    # Allows outbound traffic to Tier1 subnet.
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

    # Allows outbound traffic to IBM MQ subnet.
    [ for i, subnet in local.account_vars.ibm_mq_subnets_list :
      {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound traffic to RBUA private subnet.
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

    # Allows outbound traffic to Salesbase subnets
    [ for i, subnet in local.account_vars.salesbase_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound traffic to Salesbase subnets
    [ for i, subnet in local.account_vars.salesbase_aws_subnets_list :
      {
        rule_number = 500 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  )
}