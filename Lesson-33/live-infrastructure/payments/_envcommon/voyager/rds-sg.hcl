dependency "voyager-sg" { config_path = find_in_parent_folders("sg") }

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
    local.account_vars.locals.ips["aval-common-test"],
    local.account_vars.locals.pools["ho-pool-payments"],
    local.account_vars.locals.pools["ho-pool-dba"],
    local.account_vars.locals.pools["ho-pool-ho-dir"],
    local.account_vars.locals.dbs["imperator"],
    local.account_vars.locals.ips["yupi"],
    local.account_vars.locals.ips["mirinda"],
    local.account_vars.locals.aws_accounts["data-dev-02-internal"],
    local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-internal"],
  )

  ingress_with_cidr_blocks = [
    { from_port : 1433, to_port : 1433, protocol : "tcp", description : "DB port" },
  ]
  ingress_with_source_security_group_id = [
    { from_port : 1433, to_port : 1433, protocol : "tcp", source_security_group_id : dependency.voyager-sg.outputs.security_group_id, description : "voyager-common-sg" },
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
    { from_port : 135, to_port : 135, protocol : "tcp", description : "rpc: aval-auth-test" },
    { from_port : 49152, to_port : 65535, protocol : "tcp", description : "Ephemeral ports for RPC: aval-auth-test" },
    { from_port : 49152, to_port : 65535, protocol : "udp", description : "Ephemeral ports for RPC: aval-auth-test" },
    { from_port : 139, to_port : 139, protocol : "tcp", description : "Netbios: aval-auth-test" },
    { from_port : 445, to_port : 445, protocol : "tcp", description : "SMB: aval-auth-test" },
    { from_port : 1434, to_port : 1434, protocol : "udp", cidr_blocks : local.account_vars.locals.dbs["imperator"][0], description : "imperator" },
    { from_port : 1440, to_port : 1440, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"][0], description : "imperator" },
    { from_port : 5022, to_port : 5023, protocol : "tcp", cidr_blocks : local.account_vars.locals.dbs["imperator"][0], description : "imperator" },
  ]
}
