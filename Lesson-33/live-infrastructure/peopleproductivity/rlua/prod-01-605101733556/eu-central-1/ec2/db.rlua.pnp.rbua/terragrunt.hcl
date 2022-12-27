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
dependency "sg_db_rlua" {
    config_path = find_in_parent_folders("sg/db.rlua")
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
    ami           = "ami-0f4972b80ccdae63b" #"ami-068a4583c35cb2487"
    instance_type = "m6a.large"
    attach_ebs    = false
    ebs_optimized = true
    ebs_size_gb   = 400
    ebs_type      = "gp3"
    ebs_availability_zone = "eu-central-1b"
    subnet_id     = dependency.vpc.outputs.db_subnets.ids[0]
    key_name      = "rlua-default-pem"
    tags          = local.tags_map
    
    create_iam_role_ssm = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        dependency.sg_db_rlua.outputs.security_group_id,


    ]
}