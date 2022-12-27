dependency "trust-sg" { config_path = find_in_parent_folders("sg") }

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${local.app_vars.locals.name}"
  sg_rules     = local.account_vars.locals.environment == "test" ? concat(local.account_vars.locals.ips["yupi"], local.account_vars.locals.ips["b2x"], local.account_vars.locals.ips["sierra"]) : concat(local.account_vars.locals.ips["zuko"], local.account_vars.locals.ips["mirinda"], local.account_vars.locals.ips["soda"], local.account_vars.locals.aws_accounts["cbs-prod-01-internal"], local.account_vars.locals.aws_accounts["cbs-prod-01-restricted"])
}

inputs = {
  name            = local.name
  use_name_prefix = false
  description     = "Security group for ${local.app_vars.locals.name} RDS"
  vpc_id          = local.account_vars.locals.vpc
  tags            = local.app_vars.locals.tags

  ingress_cidr_blocks = concat(
    local.sg_rules,
    local.account_vars.locals.ips["aval-common-test"],
    local.account_vars.locals.ips["broker"],
    local.account_vars.locals.ips["avalaunch-k8s-nat"],
    local.account_vars.locals.ips["tampa-on-premise"],
    local.account_vars.locals.ips["gdwh"],
    local.account_vars.locals.pools["ho-pool-dbaho"],
    local.account_vars.locals.pools["ho-pool-payments"],
    local.account_vars.locals.pools["ho-pool-vpps"],
    local.account_vars.locals.pools["ho-pool-treasury"],
    local.account_vars.locals.pools["ho-pool-opc10"],
    local.account_vars.locals.pools["ho-pool-dba"],
    local.account_vars.locals.pools["ho-pool-ho-dir"],
    local.account_vars.locals.aws_accounts["avalaunch-dev-mig-2k3h-internal"],
    local.account_vars.locals.ips["b2admin"],
  )

  ingress_with_cidr_blocks = [
    { from_port : 1521, to_port : 1521, protocol : "tcp", description : "Oracle DB" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", description : "Oracle DB SSL" },
  ]
  ingress_with_source_security_group_id = [
    { from_port : 1521, to_port : 1521, protocol : "tcp", source_security_group_id : dependency.trust-sg.outputs.security_group_id, description : "trust-common-sg" },
    { from_port : 1575, to_port : 1575, protocol : "tcp", source_security_group_id : dependency.trust-sg.outputs.security_group_id, description : "trust-common-sg" },
  ]
  egress_with_cidr_blocks = [
    { from_port : 1521, to_port : 1521, protocol : "tcp", cidr_blocks = local.account_vars.locals.dbs["rightpool-odb"][0], description : "rightpool-odb" },
  ]
}
