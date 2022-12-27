dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

terraform {
  source = local.account_vars.locals.sources["nacl"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  description = "NACL for the Internal subnets"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = merge(local.account_vars.locals.tags, { Name = "NACL-RBUA-${upper(substr(local.account_vars.locals.environment, 0, 1))}-IN-001" })
  subnet_ids  = dependency.vpc.outputs.app_subnets.ids


  inbound_acl_rules = concat(flatten([ for bnum, cidr_blocks in {
      "200" = dependency.vpc.outputs.db_subnet_cidr_blocks,
      "300" = dependency.vpc.outputs.lb_subnet_cidr_blocks,
      "400" = dependency.vpc.outputs.public_subnet_cidr_blocks,
      "500" = local.account_vars.locals.ips["cyber_ark_net"],
      "600" = local.account_vars.locals.ips["ad"],
      "700" = local.account_vars.locals.ips["cloudflare-ips"],
      "800" = local.account_vars.locals.ips["upc"],
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
  ]),
    [
      {
        rule_number = 105
        rule_action = "allow"
        from_port   = 32768
        to_port     = 61000
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
  ])
  
  outbound_acl_rules = concat(flatten([ for bnum, cidr_blocks in {
      "200" = dependency.vpc.outputs.db_subnet_cidr_blocks,
      "300" = dependency.vpc.outputs.lb_subnet_cidr_blocks,
      "400" = dependency.vpc.outputs.public_subnet_cidr_blocks,
      "500" = local.account_vars.locals.ips["cyber_ark_net"],
      "600" = local.account_vars.locals.ips["ad"],
      "700" = local.account_vars.locals.ips["cloudflare-ips"],
      "800" = local.account_vars.locals.ips["upc"],
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
    ]),
    [
      {
        rule_number = 105
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
  ])

}