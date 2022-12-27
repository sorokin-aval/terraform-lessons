include { 
    path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
    config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

dependency "sg_infra" {
    config_path = find_in_parent_folders("sg/infra")
}
dependency "sg_https" {
    config_path = find_in_parent_folders("sg/https")
}
dependency "sg_egress-all" {
    config_path = find_in_parent_folders("sg/egress-all")
}

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags)
  user_data    = "${file("user_data.ps1")}"  
  name = basename(get_terragrunt_dir())
    
}

inputs = {
    name          = local.name
    ami           = "ami-0ee8a7f353620eece"
    instance_type = "t3a.medium"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[1]
    key_name      = "pnp-default-pem"
    tags          = local.tags_map
    create_iam_role_ssm = true
    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_https.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        
    ]
    user_data = local.user_data
}

