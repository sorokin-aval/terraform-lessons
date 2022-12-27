include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-InstancePegasus"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for app instance"
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
      name        = "App Ports"
      from_port   = 8080
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to application from CF"
      cidr_blocks = local.account_vars.cloud_flare_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Allow access for Zabbix"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Allow access for Zabbix"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS access from private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "App Ports"
      from_port   = 8080
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to application from account public subnets"
      cidr_blocks = local.account_vars.public_subnets
    },
    {
      name        = "App Ports"
      from_port   = 8080
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to application from account private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
  ]
  egress_with_cidr_blocks = [
    {
      name        = "Ldap"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to AWS Ldap"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "App"
      from_port   = 8080
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to applications from account private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "App"
      from_port   = 8080
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to applications from account public subnets"
      cidr_blocks = local.account_vars.public_subnets
    },
    {
      name        = "Kerberos"
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Access to AWS Ldap for Kerberos"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "Kerberos"
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Access to AWS Ldap for Kerberos"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "DB"
      from_port   = 4100
      to_port     = 4100
      protocol    = "tcp"
      description = "Access to DBs"
      cidr_blocks = local.account_vars.db_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "Access to Zabbix servers"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
   {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow outbound HTTPS access"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "MessDB"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Allow access to RO Mess DB"
      cidr_blocks = local.account_vars.messdb_subnets
    },
    {
      name        = "SMTP"
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "Allow access to Amazon SES endpoint"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Allow connections to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
  ]
}
