include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc_info")
}

dependency "sg_ORACLE_DB" {
  config_path = "../../sg/ORACLE_DB"
}
dependency "sg_commvault" {
  config_path = "../../sg/CommVault"
}

dependency "sg_ZabbixAgent" {
  config_path = "../../sg/ZabbixAgent"
}
dependency "sg_HTTP" {
  config_path = "../../sg/HTTP"
}

locals {
  aws_account_id = local.account_vars.locals.aws_account_id

  name = basename(get_terragrunt_dir())
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  current_tags = read_terragrunt_config("tags.hcl")
  volume_tags = read_terragrunt_config("volume_tags.hcl")
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map, local.local_tags_map)
  volume_tags_map = merge(local.common_tags_map, local.volume_tags.locals)

}

inputs = {
    name  = local.name
    ami           = "ami-0fbe087a76eb906df" 
    instance_type = "x2iedn.8xlarge" 
    subnet_id     = dependency.vpc.outputs.db_subnets.ids[1]
    key_name = local.account_vars.locals.ssh_key_name
    tags = local.tags_map
    volume_tags = local.volume_tags_map

    iam_instance_profile = "ssm-s3-full-4-ec2"
    create_iam_role_ssm = false
    create_security_group_inline = false
 
    vpc_security_group_ids = [
        dependency.sg_ORACLE_DB.outputs.security_group_id,
        dependency.sg_commvault.outputs.security_group_id,
        dependency.sg_ZabbixAgent.outputs.security_group_id,
        dependency.sg_HTTP.outputs.security_group_id
        ]
}
