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
dependency "sg_rpa-c-iclient" {
    config_path = find_in_parent_folders("sg/rpa-c-iclient")
}

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}
 
locals {
  tags = {
    "business:product-owner" = "arkadii.vygivskyi@raiffeisen.ua",
    "business:emergency-contact" = "arkadii.vygivskyi@raiffeisen.ua",
    "platform:backup" = "Daily-3day-Retention",
    "map-migrated" = "d-server-01nq8lwgqyyebr",
    "map-dba" = "d-server-01nq8lwgqyyebr",
    "business:product-project" = "BLUEPRISME",
    "product" = "BLUEPRISME",
    "ea:application-id" = "17894",
    "ea:application-name" = "Blue Prism",
    "domain" = "PnP"
  }
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags, local.tags)

  name = basename(get_terragrunt_dir())
}

inputs = {
    name          = local.name
    ami           = "ami-00dfc43892d727d11"
    instance_type = "t2.medium"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
    #key_name      = "rlua-default-pem"
    tags          = local.tags_map
    
    create_iam_role_ssm = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        dependency.sg_rpa-c-iclient.outputs.security_group_id,
    ]
}