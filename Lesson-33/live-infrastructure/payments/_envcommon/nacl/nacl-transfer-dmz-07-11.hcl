dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

terraform {
  source = local.account_vars.locals.sources["nacl"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  description = "NACL for the Transfer subnets"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = merge(local.account_vars.locals.tags, { Name = "NACL-RBUA-${upper(substr(local.account_vars.locals.environment, 0, 1))}-TR-001" })
  subnet_ids  = dependency.vpc.outputs.lb_subnets.ids


  inbound_acl_rules = flatten([ for bnum, cidr_blocks in {
      "200" = dependency.vpc.outputs.app_subnet_cidr_blocks,
      "300" = dependency.vpc.outputs.db_subnet_cidr_blocks,
      "400" = local.account_vars.locals.ips["cloudflare-ips"],
      "500" = local.account_vars.locals.pools["ho-pool-card"],
      "600" = local.account_vars.locals.ips["ibm-mb"],
      "700" = local.account_vars.locals.pools["ho-pool-opc10"],
      "800" = local.account_vars.locals.pools["ho-pool-fairo"],
      "900" = local.account_vars.locals.pools["ho-pool-ho-dir"],
      "1000" = local.account_vars.locals.ips["aval-common-test"],
      "1100" = local.account_vars.locals.ips["zuko"],
#      "1200" = local.account_vars.locals.ips["mirinda"],
      "1300" = local.account_vars.locals.pools["ho-pool-vdi"],
      "1400" = local.account_vars.locals.aws_accounts["dev-mig-2k3h"]
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
      "300" = dependency.vpc.outputs.db_subnet_cidr_blocks,
      "400" = local.account_vars.locals.ips["cloudflare-ips"],
      "500" = local.account_vars.locals.pools["ho-pool-card"],
      "600" = local.account_vars.locals.ips["ibm-mb"],
      "700" = local.account_vars.locals.pools["ho-pool-opc10"],
      "800" = local.account_vars.locals.pools["ho-pool-fairo"],
      "900" = local.account_vars.locals.pools["ho-pool-ho-dir"],
      "1000" = local.account_vars.locals.ips["aval-common-test"],
      "1100" = local.account_vars.locals.ips["zuko"],
#      "1200" = local.account_vars.locals.ips["mirinda"],
      "1300" = local.account_vars.locals.pools["ho-pool-vdi"],
      "1400" = local.account_vars.locals.aws_accounts["dev-mig-2k3h"]
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