dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name            = basename(get_terragrunt_dir())
  use_name_prefix = false
  description     = "Common security group for observability"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.account_vars.locals.tags

  ingress_cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
  ingress_rules       = ["all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Zabbix-service port"
    },
    {
      from_port   = 19080
      to_port     = 19082
      protocol    = "tcp"
      description = "Zabbix JMX monitoring"
    },
    {
      from_port   = 1521
      to_port     = 1522
      protocol    = "tcp"
      description = "DB monitoring (Zabbix, Nagios)"
    },
    {
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "DB monitoringi (Zabbix, Nagios)"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "DB monitoring (Nagios)"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Zabbix"
      cidr_blocks = local.account_vars.locals.ips["zabbix"][0]
    },
  ]

  egress_cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
  egress_with_cidr_blocks = [
    {
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Zabbix-service port"
    },
    {
      from_port   = 514
      to_port     = 514
      protocol    = "udp"
      description = "DB syslog"
      cidr_blocks = local.account_vars.locals.ips["db-syslog"]
    },
  ]
  egress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "ssm-vpc-endpoint"
      source_security_group_id = "${dependency.ssm-vpc-endpoint.outputs.security_group_id}"
    },
  ]
}
