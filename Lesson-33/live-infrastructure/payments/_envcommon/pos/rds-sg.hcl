dependency "ap01-ejbca" { config_path = find_in_parent_folders("ejbca/ap01.ejbca") }
dependency "ap02-ejbca" { config_path = find_in_parent_folders("ejbca/ap02.ejbca") }

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${local.app_vars.locals.name}"
}

inputs = {
  name                = local.name
  use_name_prefix     = false
  description         = "Security group for ${local.app_vars.locals.name} RDS"
  vpc_id              = local.account_vars.locals.vpc
  tags                = local.app_vars.locals.tags
  ingress_cidr_blocks = concat(
    local.account_vars.locals.pools["ho-pool-dba"], 
    local.account_vars.locals.ips["ejbca-db1"],
    ["${dependency.ap01-ejbca.outputs.ec2_private_ip}/32"],
    ["${dependency.ap02-ejbca.outputs.ec2_private_ip}/32"]
  )
  ingress_with_cidr_blocks = [
    { from_port : 3306, to_port : 3306, protocol : "tcp", description : "rds service port" },
  ]
  egress_with_cidr_blocks = []
}
