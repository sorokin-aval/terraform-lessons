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

dependency "sg_ZabbixAgent" {
  config_path = "../../sg/ZabbixAgent"
}

locals {
  name = basename(get_terragrunt_dir())
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  current_tags = read_terragrunt_config("tags.hcl")
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map, local.local_tags_map)

}

inputs = {
    name  = local.name
    ami           = "ami-057dd2f79a739373f" 
    instance_type = "t3.small" 
    subnet_id     = dependency.vpc.outputs.db_subnets.ids[2]
    key_name = dependency.vpc.outputs.ssh_key_ids[0]
    tags = local.tags_map
    volume_tags = local.tags_map

    iam_instance_profile = "test-oracle-s3-readonly"
    create_iam_role_ssm = false
    create_security_group_inline = false
 
    vpc_security_group_ids = [
        dependency.sg_ORACLE_DB.outputs.security_group_id,
        dependency.sg_commvault.outputs.security_group_id,
        dependency.sg_ZabbixAgent.outputs.security_group_id
        ]
}
