dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LRARdsArch"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the RDS Arch DB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = concat(
    [
      {
        name        = "From internal subnets"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "Access from internal subnets"
        cidr_blocks = local.account_vars.tier2_subnets
      },
      {
        name        = "From support subnets"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "Access from support subnets"
        cidr_blocks = local.account_vars.support_access_subnets
      },
      {
        name        = "From Zabbix subnets"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "Access from Zabbix subnets"
        cidr_blocks = local.account_vars.common_infra_subnets
      },
    ],
    [ for subnet in local.account_vars.inbound_db_arch_subnets_list :
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
  )
  egress_with_cidr_blocks = []
}
