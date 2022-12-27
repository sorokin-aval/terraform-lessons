dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name            = basename(get_terragrunt_dir())
  use_name_prefix = false
  description     = "Common security group for RDP"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.account_vars.locals.tags

  ingress_prefix_list_ids = ["pl-07b762cf9bdecee02"] #rbua_cyber_ark_nets 
  ingress_rules           = ["rdp-tcp", "rdp-udp"]
}
