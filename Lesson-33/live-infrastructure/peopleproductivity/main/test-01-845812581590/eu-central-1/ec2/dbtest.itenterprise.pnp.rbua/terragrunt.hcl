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
dependency "sg_db-interprise-sg" {
    config_path = find_in_parent_folders("sg/db-interprise-sg")
}

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

locals {
   tags = {
    "business:product-owner" = "andrii.martsynenko@raiffeisen.ua",
    "business:emergency-contact" = "oleksandr.derkach@raiffeisen.ua",
    "platform:backup" = "Daily-3day-Retention",
    "ea:application-id" = "21288",
    "ea:application-name" = "IT-Enterprase",
    "map-migrated" = "NA",
    "map-dba" = "NA",
    "product" = "IT-Enterprase"
  }  
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags, local.tags)

  name = basename(get_terragrunt_dir())
}
 
inputs = {
    name          = local.name
    ami           = "ami-068a4583c35cb2487"
    instance_type = "m6a.large"
    attach_ebs    = true
    ebs_optimized = true
    ebs_size_gb   = 150
    ebs_type      = "gp3"
    ebs_availability_zone = "eu-central-1b"
    subnet_id     = dependency.vpc.outputs.db_subnets.ids[1]
    key_name      = "test-01-default"
    tags          = local.tags_map
    
    create_iam_role_ssm = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        dependency.sg_db-interprise-sg.outputs.security_group_id,
    
   ]
}
