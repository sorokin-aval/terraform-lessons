include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=ec2_v0.0.2"
}

dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}

dependency "sg_ORACLE_DB_CISAOD" {
  config_path = "../../sg/Oracle_DB_Cisaod"
}

dependency "sg_ZabbixAgent" {
  config_path = "../../sg/ZabbixAgent"
}

iam_role = local.account_vars.iam_role

locals {
  aws_account_id  = local.account_vars.locals.aws_account_id
  current_tags    = read_terragrunt_config("tags.hcl")
  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags_map = local.common_tags.locals
  local_tags_map  = local.current_tags.locals
  tags_map        = merge(local.common_tags_map, local.local_tags_map)
  name            = basename(get_terragrunt_dir())
}

inputs = {
  name          = local.name
  ami           = "ami-0c7a924817f296835"
  instance_type = "r5.2xlarge"
  subnet_id     = dependency.vpc.outputs.db_subnets.ids[2]
  key_name      = dependency.vpc.outputs.ssh_key_ids[0]
  tags          = local.tags_map
  volume_tags   = local.tags_map

  disable_api_termination = true
  disable_api_stop        = true

  create_iam_role_ssm  = false
  iam_instance_profile = "ssm-corebanking-role"

  create_security_group_inline = false
  vpc_security_group_ids = [
    dependency.sg_ORACLE_DB_CISAOD.outputs.security_group_id,
    dependency.sg_ZabbixAgent.outputs.security_group_id
  ]

}
