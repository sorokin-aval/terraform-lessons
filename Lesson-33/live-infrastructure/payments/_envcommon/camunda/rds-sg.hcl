terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${local.app_vars.locals.name}"
}

inputs = {
  name            = local.name
  use_name_prefix = false
  description     = "Security group for ${local.app_vars.locals.name} RDS"
  vpc_id          = local.account_vars.locals.vpc
  tags            = local.app_vars.locals.tags

  ingress_cidr_blocks = concat(
    local.account_vars.locals.pools["ho-pool-dba"],
    local.account_vars.locals.dbs["bpm"],
  )

  ingress_with_cidr_blocks = [
    { from_port : 5432, to_port : 5432, protocol : "tcp", description : "DB port" },
  ]
  egress_cidr_blocks = local.account_vars.locals.aws_accounts["aval-auth-test-transfer"]
  egress_with_cidr_blocks = [
    { from_port : 53, to_port : 53, protocol : "tcp", description : "DNS: aval-auth-test" },
    { from_port : 53, to_port : 53, protocol : "udp", description : "DNS: aval-auth-test" },
    { from_port : 88, to_port : 88, protocol : "tcp", description : "Kerberos: aval-auth-test" },
    { from_port : 88, to_port : 88, protocol : "udp", description : "Kerberos: aval-auth-test" },
    { from_port : 464, to_port : 464, protocol : "tcp", description : "Kerberos: aval-auth-test" },
    { from_port : 464, to_port : 464, protocol : "udp", description : "Kerberos: aval-auth-test" },

    { from_port : 389, to_port : 389, protocol : "tcp", description : "ldap: aval-auth-test" },
    { from_port : 389, to_port : 389, protocol : "udp", description : "ldap: aval-auth-test" },

    { from_port : 135, to_port : 135, protocol : "tcp", description : "RPC, EPM: Replication" },
    { from_port : 49152, to_port : 65535, protocol : "tcp", description : "RPC" },

  ]
}
