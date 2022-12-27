dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-RDSDBLipton"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the Webpromo DB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = concat(
    [
      {
        name        = "MariaDB"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allow access from Tier1 subnets"
        cidr_blocks = local.account_vars.tier1_subnets
      },
      {
        name        = "MariaDB"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allow access from Salesbase"
        cidr_blocks = local.account_vars.salesbase_subnets
      },
      {
        name        = "MariaDB"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allow access from Zabbix server"
        cidr_blocks = local.account_vars.zabbix_subnets
      },
      {
        name        = "MariaDB"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allow access from Lipton on-premise subnets"
        cidr_blocks = local.account_vars.lipton_onpremise_subnets
      },
      {
        name        = "MariaDB"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allow access from DBRE private pool"
        cidr_blocks = local.account_vars.dbre_private_subnets
      },
      {
        name        = "MariaDB"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "Allow access from DBRE private pool"
        cidr_blocks = local.account_vars.salesbase_aws_subnets
      },
    ],
    [ for subnet in local.account_vars.salesbase_onprem_subnets_list :
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = subnet.description
        cidr_blocks = subnet.cidr
      }
    ],
  )
  egress_with_cidr_blocks = [
  ]
}
