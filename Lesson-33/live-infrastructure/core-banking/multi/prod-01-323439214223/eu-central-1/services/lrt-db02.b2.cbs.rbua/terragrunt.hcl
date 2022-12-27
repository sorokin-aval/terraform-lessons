include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}

dependency "sg_ORACLE_DB" {
  config_path = "../../sg/ORACLE_DB"
}
dependency "sg_commvault" {
  config_path = "../../sg/CommVault"
}

dependency "sg_cross_oracledb" {
  config_path = "../../sg/cross_oracledb"
}

dependency "sg_ZabbixAgent" {
  config_path = "../../sg/ZabbixAgent"
}

iam_role = local.account_vars.iam_role

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  common_tags    = read_terragrunt_config("tags.hcl")
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map       = local.common_tags.locals
  name           = basename(get_terragrunt_dir())
}

inputs = {
  name          = local.name
  ami           = "ami-044fe120b75a73714"
  instance_type = "x2iedn.8xlarge"
  subnet_id     = dependency.vpc.outputs.db_subnets.ids[1]
  key_name      = dependency.vpc.outputs.ssh_key_ids[0]
  tags          = local.tags_map
  volume_tags   = local.tags_map

  iam_instance_profile         = "ssm-corebanking-role"
  create_iam_role_ssm          = false
  create_security_group_inline = false

  vpc_security_group_ids = [
    dependency.sg_ORACLE_DB.outputs.security_group_id,
    dependency.sg_commvault.outputs.security_group_id,
    dependency.sg_cross_oracledb.outputs.security_group_id,
    dependency.sg_ZabbixAgent.outputs.security_group_id
  ]
}
