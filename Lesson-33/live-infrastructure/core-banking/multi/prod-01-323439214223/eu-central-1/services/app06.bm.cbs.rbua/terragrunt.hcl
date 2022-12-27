include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}




dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}

dependency "sg_Antivir" {
  config_path = "../../sg/Antivirus"
}

dependency "sg_AuditLogOut" {
  config_path = "../../sg/AuditLogs"
}

dependency "sg_ZabbixAgent" {
  config_path = "../../sg/Tuxedo"
}

dependency "sg_Tuxedo" {
  config_path = "../../sg/ZabbixAgent"
}

dependency "sg_ControlMAgent" {
  config_path = "../../sg/ControlMAgent"
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

  name = "app06.bm.cbs.rbua"
}

inputs = {
  name                 = local.name
  iam_instance_profile = "ssm-corebanking-role"

  create_iam_role_ssm = false

  ami                     = "ami-0aff61c704efdc9eb"
  instance_type           = "t3.xlarge"
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[0]
  key_name                = dependency.vpc.outputs.ssh_key_ids[0]
  tags                    = local.tags_map
  volume_tags             = local.tags_map
  disable_api_termination = true
  monitoring              = true

  create_security_group_inline = false
  vpc_security_group_ids = [
    dependency.sg_Antivir.outputs.security_group_id,
    dependency.sg_AuditLogOut.outputs.security_group_id,
    dependency.sg_Tuxedo.outputs.security_group_id,
    dependency.sg_ZabbixAgent.outputs.security_group_id,
    dependency.sg_ControlMAgent.outputs.security_group_id
  ]


}
