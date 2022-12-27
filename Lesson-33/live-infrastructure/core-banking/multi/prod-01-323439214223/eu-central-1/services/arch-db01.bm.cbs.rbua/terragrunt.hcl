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
  ami           = "ami-0e23c487ce73b3477"
  instance_type = "r5b.2xlarge"
  subnet_id     = dependency.vpc.outputs.db_subnets.ids[0]
  key_name      = dependency.vpc.outputs.ssh_key_ids[0]
  tags          = local.tags_map
  volume_tags   = local.tags_map

  iam_instance_profile = "ssm-corebanking-role"
  create_iam_role_ssm  = false

  create_security_group_inline = false
  vpc_security_group_ids = [
    dependency.sg_ORACLE_DB.outputs.security_group_id,
    dependency.sg_commvault.outputs.security_group_id,
  ]

}
