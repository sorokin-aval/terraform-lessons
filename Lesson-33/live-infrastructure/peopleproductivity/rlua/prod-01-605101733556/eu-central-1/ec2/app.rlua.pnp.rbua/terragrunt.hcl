include { 
    path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
    config_path = find_in_parent_folders("core-infrastructure/vpc-info",find_in_parent_folders("vpc-info")) 
}

dependency "sg_infra" {
    config_path = find_in_parent_folders("sg/infra")
}
dependency "sg_egress-all" {
    config_path = find_in_parent_folders("sg/egress-all")
}
dependency "sg_app-rlua" {
    config_path = find_in_parent_folders("sg/app.rlua")
}


terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}
 
locals {
  tags = {
    "business:product-owner" = "dmytro.barysh@raiffeisen.ua",
    "business:emergency-contact" = "dmytro.barysh@raiffeisen.ua",
    "platform:backup" = "Daily-3day-Retention"
  }
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags, local.tags)

  name = basename(get_terragrunt_dir())
}

inputs = {
    name          = local.name
    #ami           = "ami-0c2e8e3e554f8da89"
    ami           = "ami-0c280da9abfa31d86"
    instance_type = "t3a.large"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
    key_name      = "rlua-default-pem"
    tags          = local.tags_map
    #iam_instance_profile = "DescribeTags-Secret"
    #user_data     = local.user_data
    
    create_iam_role_ssm = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        dependency.sg_app-rlua.outputs.security_group_id
    ]
}