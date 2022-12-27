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
  subnet_ids  = dependency.vpc.outputs.app_subnets.ids


  ############## Inbound ##############

  inbound_acl_rules = concat(
    # Allows inbound SSH traffic from CyberArk subnets
    [ for i, subnet in local.account_vars.cyberark_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows ICMP from Zabbix subnets
    [ for i, subnet in local.account_vars.zabbix_subnets_list :
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

    # Allows inbound return traffic (that is, for requests that originate in the subnet)
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

    # Allows inbound HTTPS traffic from public subnets
    [ for i, subnet in local.account_vars.public_subnets_list :
      {
        rule_number = 400 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound HTTPS traffic from tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 500 + i
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
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  
      # Allows inbound HTTPS traffic from Zabbix private subnets
    [ for i, subnet in local.account_vars.zabbix_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound SSH traffic from CMFront on-premise subnets
    [ for i, subnet in local.account_vars.cmsfont_onpemise_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows SMTP traffic to Amazon SES
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 900 + i
        rule_action = "allow"
        from_port   = 587
        to_port     = 587
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  )


  ############## Outbound ##############

  outbound_acl_rules = concat(
    # Allows access to CMSFront in Tier1 subnets
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 100 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows ICMP responses to Zabbix subnets
    [ for i, subnet in local.account_vars.zabbix_subnets_list :
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

    # Allows outbound HTTPS to Google services.
    [
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound HTTP to Finlocator.
    [
      {
        rule_number = 400
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ],

    # Allows outbound access to Active Directory Cloud
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

    # Allows outbound access to Active Directory Cloud without TLS for CMS admin part
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 600 + i
        rule_action = "allow"
        from_port   = 389
        to_port     = 389
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud for Kerberos auth
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 700 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows outbound access to Active Directory Cloud for Kerberos auth
    [ for i, subnet in local.account_vars.ad_aws_subnets_list :
      {
        rule_number = 800 + i
        rule_action = "allow"
        from_port   = 88
        to_port     = 88
        protocol    = "udp"
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

    # Allows return traffic to RBUA AWS private subnets
    [ for i, subnet in local.account_vars.rbua_private_aws_subnets_list :
      {
        rule_number = 1000 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows return traffic to RBUA on-premise private subnets
    [ for i, subnet in local.account_vars.rbua_private_subnets_list :
      {
        rule_number = 1100 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows SMTP traffic to Amazon SES
    [ for i, subnet in local.account_vars.tier1_subnets_list :
      {
        rule_number = 1200 + i
        rule_action = "allow"
        from_port   = 587
        to_port     = 587
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],

    # Allows inbound SSH traffic to CMFront on-premise subnets
    [ for i, subnet in local.account_vars.cmsfont_onpemise_subnets_list :
      {
        rule_number = 1300 + i
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = subnet
      }
    ],
  )
}