terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  name            = local.app_vars.locals.name
  use_name_prefix = false
  description     = "Common security group for ${local.app_vars.locals.name}"
  vpc_id          = local.account_vars.locals.vpc
  tags            = local.app_vars.locals.tags
  ingress_with_cidr_blocks = [
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["v-cardtr.tmydb"][0], description : "v-cardtr.tmydb" },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["unistatement1.mydb"][0], description : "unistatement1.mydb" },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["unistatement2.mydb"][0], description : "unistatement2.mydb" },
    { from_port : 5432, to_port : 5432, protocol : "tcp", cidr_blocks : local.account_vars.locals.pools["ho-pool-dba"][0], description : "ho-pool-dba" },
  ]
  egress_cidr_blocks = local.account_vars.locals.aws_accounts["aval-auth-test-transfer"]
  egress_with_cidr_blocks = [
    { from_port : 53, to_port : 53, protocol : "tcp", description : "DNS: aval-auth-test" },
    { from_port : 53, to_port : 53, protocol : "udp", description : "DNS: aval-auth-test" },
    { from_port : 88, to_port : 88, protocol : "tcp", description : "Kerberos: aval-auth-test" },
    { from_port : 88, to_port : 88, protocol : "udp", description : "Kerberos: aval-auth-test" },
    { from_port : 464, to_port : 464, protocol : "tcp", description : "Kerberos: aval-auth-test" },
    { from_port : 464, to_port : 464, protocol : "udp", description : "Kerberos: aval-auth-test" },
  ]
}
