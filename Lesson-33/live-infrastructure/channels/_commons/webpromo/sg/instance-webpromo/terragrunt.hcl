dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-InstanceWebpromo"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the Webpromo instance"
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
      description = "HTTPS access from ALB private subnets"
      cidr_blocks = local.account_vars.tier1_subnets
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
      name        = "HTTPS"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "HTTPS access from ALB private subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access from public ALB"
      cidr_blocks = local.account_vars.public_subnets
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
      name        = "SMTP"
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "Allow access to Amazon SES endpoint"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "MariaDB"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow access to RDS"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS access"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
