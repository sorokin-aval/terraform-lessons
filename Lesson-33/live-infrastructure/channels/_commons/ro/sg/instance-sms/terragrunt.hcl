dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIAInstanceSMS"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the SMS instance"
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
      name        = "HTTPS"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access from tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
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
      name        = "HTTPS"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access from specified subnets"
      cidr_blocks = local.account_vars.inbound_sms_subnets
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
      from_port   = 1575
      to_port     = 1576
      protocol    = "tcp"
      description = "Access to DB NLB"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "Oracle DB Direct"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access to DB Direct"
      cidr_blocks = local.account_vars.db_subnets
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access to services in the tier2 subnets"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access to services in the tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
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
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Access to Logstash"
      cidr_blocks = local.account_vars.logstash_subnets
    },
    {
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Access to Logstash LB"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "AppDynamics, Google/Huawei Clouds, etc."
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS for AppDynamics, Google/Huawei Clouds, etc."
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "Apple Cloud Push"
      from_port   = 2195
      to_port     = 2196
      protocol    = "tcp"
      description = "Allow Apple Cloud Push notifications"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "SMTP"
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "Allow SMTP VPC Endpoint access"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "SMS GW"
      from_port   = 2777
      to_port     = 2777
      protocol    = "tcp"
      description = "Allow SMS GW"
      cidr_blocks = local.account_vars.sms_gw_vpn_subnets
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
      name        = "SMPP GW"
      from_port   = 20520
      to_port     = 20520
      protocol    = "tcp"
      description = "Allow SMPP GW"
      cidr_blocks = local.account_vars.smpp_gw_subnets
    },
    {
      name        = "3Mob SMS GW"
      from_port   = 3339
      to_port     = 3339
      protocol    = "tcp"
      description = "Allow 3Mob SMS GW"
      cidr_blocks = local.account_vars.threemob_gw_vpn_subnets
    },
    {
      name        = "GMSU SMS GW"
      from_port   = 20510
      to_port     = 20510
      protocol    = "tcp"
      description = "Allow GMSU SMS GW"
      cidr_blocks = local.account_vars.gmsu_gw_vpn_subnets
    },
    {
      name        = "Kyivstar SMS GW"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow Kyivstar SMS GW"
      cidr_blocks = local.account_vars.kyivstar_gw_vpn_subnets
    },
    {
      name        = "Lifecell SMS GW"
      from_port   = 16001
      to_port     = 16001
      protocol    = "tcp"
      description = "Allow Lifecell SMS GW"
      cidr_blocks = local.account_vars.lifecell_gw_vpn_subnets
    },
  ]
}
