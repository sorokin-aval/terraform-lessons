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
dependency "sg_egress-all" {
    config_path = find_in_parent_folders("sg/egress-all")
}
dependency "sg_uadho-hpweb-c-sg" {
    config_path = find_in_parent_folders("sg/uadho-hpweb-c-sg")
}

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags)

  name = basename(get_terragrunt_dir())


}
 
inputs = {
    name          = local.name
    ami           = "ami-0546ec21017b44001"
    instance_type = "t3.medium"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
    #key_name      = "pnp-default-pem"
    tags          = local.tags_map
       
    create_iam_role_ssm = true
 
    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_uadho-hpweb-c-sg.outputs.security_group_id,
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        
       ]
}
