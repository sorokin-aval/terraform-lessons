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
  name         = "SG-RBUA-InstanceHAProxy"
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
      description = "SSH access from CyberArk private subnets"
      cidr_blocks = local.account_vars.cyberark_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access to application from CF"
      cidr_blocks = local.account_vars.cloud_flare_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access to application from account public subnets"
      cidr_blocks = local.account_vars.public_subnets
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
      name        = "Stat Port"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      description = "Allow access from account private subnets to HAProxy stat page"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "HAProxy"
      from_port   = 12346
      to_port     = 12346
      protocol    = "tcp"
      description = "Access between HAProxy instances"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "Zabbix Ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Allow ICMP"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
  ]
  egress_with_cidr_blocks = [
    {
      name        = "App"
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "Access to Bifit applications"
      cidr_blocks = local.account_vars.tier1_subnets
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
      name        = "Zabbix"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "Access to Zabbix servers"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "HAProxy"
      from_port   = 12346
      to_port     = 12346
      protocol    = "tcp"
      description = "Access between HAProxy instances"
      cidr_blocks = local.account_vars.tier1_subnets
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
      name        = "Logstash"
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Allow access to opesearch cluster"
      cidr_blocks = local.account_vars.logstash_subnets
    },
  ]
}
