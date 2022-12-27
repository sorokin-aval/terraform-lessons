dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

terraform {
  source = local.account_vars.locals.sources["nacl"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  description = "NACL for the Restricted subnets"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = merge(local.account_vars.locals.tags, { Name = "NACL-RBUA-${upper(substr(local.account_vars.locals.environment, 0, 1))}-RE-001" })
  subnet_ids  = dependency.vpc.outputs.db_subnets.ids


  inbound_acl_rules = flatten([ for bnum, cidr_blocks in {
      "200" = dependency.vpc.outputs.app_subnet_cidr_blocks,
      "300" = dependency.vpc.outputs.lb_subnet_cidr_blocks
      "400" = local.account_vars.locals.ips["on-premise-databases"],
      "500" = local.account_vars.locals.ips["cyber_ark_net"],
      "600" = local.account_vars.locals.pools["ho-pool-dba"],
      "700" = local.account_vars.locals.ips["aval-common-test"],
      "800" = local.account_vars.locals.ips["comm-vault"],
      "900" = local.account_vars.locals.ips["oracle-db-tf"],
      "1000" = dependency.vpc.outputs.db_subnet_cidr_blocks,
      "1100" = local.account_vars.locals.ips["zuko"],
#      "1200" = local.account_vars.locals.ips["mirinda"],
      "1300" = local.account_vars.locals.pools["ho-pool-vdi"],
      "1400" = local.account_vars.locals.pools["ho-pool-card"],
      "1500" = local.account_vars.locals.aws_accounts["dev-mig-2k3h"]
    } :
      [ for i, cidr_block in cidr_blocks :
        {
          rule_number = bnum + i
          rule_action = "allow"
          from_port   = -1
          to_port     = -1
          protocol    = "-1"
          cidr_block  = cidr_block
        }
      ]
  ])

  outbound_acl_rules = flatten([ for bnum, cidr_blocks in {
      "200" = dependency.vpc.outputs.app_subnet_cidr_blocks,
      "300" = dependency.vpc.outputs.lb_subnet_cidr_blocks
      "400" = local.account_vars.locals.ips["on-premise-databases"],
      "500" = local.account_vars.locals.ips["cyber_ark_net"],
      "600" = local.account_vars.locals.pools["ho-pool-dba"],
      "700" = local.account_vars.locals.ips["aval-common-test"],
      "800" = local.account_vars.locals.ips["comm-vault"],
      "900" = local.account_vars.locals.ips["oracle-db-tf"],
      "1000" = dependency.vpc.outputs.db_subnet_cidr_blocks,
      "1100" = local.account_vars.locals.ips["zuko"],
#      "1200" = local.account_vars.locals.ips["mirinda"],
      "1300" = local.account_vars.locals.pools["ho-pool-vdi"],
      "1400" = local.account_vars.locals.pools["ho-pool-card"],
      "1500" = local.account_vars.locals.aws_accounts["dev-mig-2k3h"]
    } :
      [ for i, cidr_block in cidr_blocks :
        {
          rule_number = bnum + i
          rule_action = "allow"
          from_port   = -1
          to_port     = -1
          protocol    = "-1"
          cidr_block  = cidr_block
        }
      ]
  ])

}