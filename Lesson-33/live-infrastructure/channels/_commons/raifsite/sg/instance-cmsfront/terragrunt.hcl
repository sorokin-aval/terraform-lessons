dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-InstanceCMSFront"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the CMSFront instance"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from CyberArk subnets"
      cidr_blocks = local.account_vars.cyberark_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access from ALB public subnets"
      cidr_blocks = local.account_vars.public_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access from private ALB SG"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 4343
      to_port     = 4343
      protocol    = "tcp"
      description = "HTTPS access to admin part from private ALB SG"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "HTTPS API"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Access from ALB public subnets on 8443"
      cidr_blocks = local.account_vars.public_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Access from Zabbix server"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "Zabbix Ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Allow ICMP"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "Elasticsearch"
      from_port   = 9203
      to_port     = 9203
      protocol    = "tcp"
      description = "Allow access to ElasticSearch cluster"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "Elasticsearch"
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      description = "Allow access to ElasticSearch cluster"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS access from Zabbix"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from CMSFront on-premise subnets"
      cidr_blocks = local.account_vars.cmsfont_onpemise_subnets
    },
  ]
  egress_with_cidr_blocks = [
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Access to Zabbix server"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to AWS Active Directory"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "Kerberos TCP"
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Access to Active Directory for Kerberos auth"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "Kerberos UDP"
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Access to Active Directory for Kerberos auth"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "ActiveMQ"
      from_port   = 61616
      to_port     = 61616
      protocol    = "tcp"
      description = "Allow connections to ActiveMQ"
      cidr_blocks = local.account_vars.activemq_subnets
    },
    {
      name        = "IBMMQ"
      from_port   = 1415
      to_port     = 1415
      protocol    = "tcp"
      description = "Allow connections to IBMMQ"
      cidr_blocks = local.account_vars.ibm_mq_subnets
    },
    {
      name        = "WSO2 ESB"
      from_port   = 8243
      to_port     = 8243
      protocol    = "tcp"
      description = "Allow connections to WSO2 ESB"
      cidr_blocks = local.account_vars.esb_subnets
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
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS access to Google Maps, Gstatic etc."
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP access to Finlocator etc."
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "Elasticsearch"
      from_port   = 9203
      to_port     = 9203
      protocol    = "tcp"
      description = "Allow access to ElasticSearch cluster"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "Elasticsearch"
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      description = "Allow access to ElasticSearch cluster"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "Redis"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Allow access to Elasticache Redis cluster"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "PostgreSQL"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Allow access to RDS"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "AD"
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "Access to AWS Active Directory without TLS"
      cidr_blocks = local.account_vars.ad_aws_subnets
    },
    {
      name        = "ActiveMQ"
      from_port   = 8243
      to_port     = 8243
      protocol    = "tcp"
      description = "Allow connections to ActiveMQ"
      cidr_blocks = local.account_vars.activemq_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Allow connections to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
    {
      name        = "EFS"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "Allow access to RDS"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "ActiveMQ"
      from_port   = 8280
      to_port     = 8280
      protocol    = "tcp"
      description = "Allow connections to ActiveMQ"
      cidr_blocks = local.account_vars.activemq_subnets
    },
    {
      name        = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from CMSFront on-premise subnets"
      cidr_blocks = local.account_vars.cmsfont_onpemise_subnets
    },
  ]
}
