include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
  ]
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/cluster-redis")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

terraform {
  source = local.account_vars.sources_elasticache
}

locals {
  name         = "cmsfront"
  subnet       = "db"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags         = local.tags_map
  token        = file("redis-creds.yml")
}

inputs = {
  name            = local.name
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.db_subnets.ids
  instance_type   = "cache.t3.medium"
  engine_version  = "6.2"
  family          = "redis6.x"
  create_security_group = "false"
  associated_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
  at_rest_encryption_enabled	= "true"
  auth_token  = yamldecode(local.token)

  tags        = local.tags

}
