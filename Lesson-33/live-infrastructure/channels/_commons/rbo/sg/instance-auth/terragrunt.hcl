dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIAInstanceAuth"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the Auth instance"
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
      name        = "HTTPS from Tier2"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access from tier2 subnets"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Access from Zabbix server"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "Zabbix Ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Allow ICMP"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "From Front"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "Allow access from Front"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "From Zabbix"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "Allow access from Zabbix"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "SSH - Ansible"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Access from Bastion host for Ansible"
      cidr_blocks = "${local.account_vars.bastion_host_ip}/32"
    }
]
  egress_with_cidr_blocks = [
    {
      name        = "Oracle DB NLB"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access to Oracle DB NLB"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "Oracle DB NLB SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access to Oracle DB NLB SSL"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "Postgres DB"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Access to Postgres DB"
      cidr_blocks = local.account_vars.tier3_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Access to Zabbix server"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "AppDynamics, etc."
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS for AppDynamics, etc."
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to Active Directory Cloud"
      cidr_blocks = local.account_vars.auth_subnets
    },
    {
      name        = "AD - Kerberos TCP"
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Access to Active Directory - Kerberos TCP"
      cidr_blocks = local.account_vars.auth_subnets
    },
    {
      name        = "AD - Kerberos UDP"
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Access to Active Directory - Kerberos UDP"
      cidr_blocks = local.account_vars.auth_subnets
    },
    {
      name        = "Internal CSK"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow access to Internal CSK"
      cidr_blocks = local.account_vars.security_subnets
    },
    {
      name        = "External CSK"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow access to External CSK"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "Internal CSK Back"
      from_port   = 8082
      to_port     = 8082
      protocol    = "tcp"
      description = "Allow access to Internal CSK Back"
      cidr_blocks = local.account_vars.security_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Access to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
    {
      name        = "RBAProxy"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "Access to RBUA Proxy"
      cidr_blocks = local.account_vars.rba_proxy_subnets
    },
  ]
}
