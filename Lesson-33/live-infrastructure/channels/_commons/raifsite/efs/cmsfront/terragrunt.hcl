dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/efs-${local.name}")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

iam_role = local.account_vars.iam_role

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
  ]
}

terraform {
  source = local.account_vars.sources_elastic_fs
}

locals {
  name         = "cmsfront"
  subnet       = "app"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags         = local.tags_map
}


inputs = {
  name			= local.name
  vpc_id		= dependency.vpc.outputs.vpc_id.id
  allowed_cidr_blocks   = local.account_vars.tier1_subnets_list
  subnets		= dependency.vpc.outputs["${local.subnet}_subnets"].ids
  encrypted		= "false"
  dns_name		= "efs-{$local.name}.{$local.account_vars.domain}"
  create_security_group = false
  associated_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]

  tags        = local.tags

}
