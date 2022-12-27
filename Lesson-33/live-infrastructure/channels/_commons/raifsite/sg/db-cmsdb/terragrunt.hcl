dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-RDSCMSDB"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for the RaifSite DB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "MariaDB"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Allow access from Tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "HTTPS access from RBUA private subnets"
      cidr_blocks = local.account_vars.rbua_private_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Access from Zabbix server"
      cidr_blocks = local.account_vars.zabbix_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Access from IBM MQ server"
      cidr_blocks = local.account_vars.ibm_mq_subnets
    },
  ]
  egress_with_cidr_blocks = [
  ]
}
