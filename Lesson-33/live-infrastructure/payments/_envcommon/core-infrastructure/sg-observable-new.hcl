dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  # source = local.account_vars.locals.sources["sg"]
  #source = "git::https://github.com/cloudposse/terraform-aws-security-group//"
  source = "tfr:///cloudposse/security-group/aws?version=1.0.1"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {

  #   {
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "tcp"
  #     description = "s3 prefix list"
  #   },

  # egress_prefix_list_ids = ["pl-6ea54007"]
  #attributes = [basename(get_terragrunt_dir())]  
  security_group_name = [basename(get_terragrunt_dir())]
  vpc_id              = dependency.vpc.outputs.vpc_id.id
  tags                = local.account_vars.locals.tags
  rules = [
    {
      key         = "zabbix"
      type        = "ingress"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
      self        = null
      description = "Zabbix-service port"
    },
    {
      key         = "zabbix-jmx"
      type        = "ingress"
      from_port   = 19080
      to_port     = 19082
      protocol    = "tcp"
      cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
      self        = null
      description = "Zabbix JMX monitoring"
    },
    {
      key         = "zabbix-db"
      type        = "ingress"
      from_port   = 1522
      to_port     = 1522
      protocol    = "tcp"
      cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
      self        = null
      description = "DB monitoring"
    },
    {
      key         = "icmp"
      type        = "ingress"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
      self        = null
      description = "All ICMP"
    },
    {
      key         = "zabbix-eg"
      type        = "egress"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      cidr_blocks = local.account_vars.locals.ips["aval-common-test"]
      self        = null
      description = "Zabbix-service port"
    },
    {
      key         = "syslog"
      type        = "egress"
      from_port   = 514
      to_port     = 514
      protocol    = "udp"
      cidr_blocks = local.account_vars.locals.ips["db-syslog"]
      self        = null
      description = "DB syslog"
    },
    {
      key             = "ssm-vpc-endpoint"
      type            = "egress"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = ["${dependency.ssm-vpc-endpoint.outputs.security_group_id}"]
      self            = null
      description     = "ssm-vpc-endpoint"
    }
  ]

}

