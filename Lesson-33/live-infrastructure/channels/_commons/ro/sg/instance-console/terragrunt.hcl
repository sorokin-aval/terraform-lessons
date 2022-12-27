dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIWInstanceConsole"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the Console instance"
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
      name        = "IBM Message Broker"
      from_port   = 1415
      to_port     = 1415
      protocol    = "tcp"
      description = "Access to IBM Message Broker"
      cidr_blocks = local.account_vars.ibm_mq_subnets
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
      name        = "On-Premise AD"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to Active Directory On-Premise"
      cidr_blocks = local.account_vars.ad_onprem_subnets
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
      name        = "AppDynamics, etc."
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS for AppDynamics, etc."
      cidr_blocks = "0.0.0.0/0"
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
      name        = "Stub"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "Access to Stub"
      cidr_blocks = local.account_vars.tier2_subnets
    },
  ]
}
