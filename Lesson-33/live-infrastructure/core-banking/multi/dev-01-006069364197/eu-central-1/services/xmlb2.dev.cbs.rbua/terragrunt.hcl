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
dependency "sg_Http" {
  config_path = "../../sg/HTTP"
}

dependency "sg_Ssh" {
  config_path = "../../sg/Ssh"
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
    ami           = "ami-033f72272e543f786" 
    instance_type = "t3.medium"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
    key_name = "platformOps"
    tags = local.tags_map
    volume_tags = local.tags_map
    disable_api_termination = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_Ssh.outputs.security_group_id,
        dependency.sg_Http.outputs.security_group_id
        ]
}
