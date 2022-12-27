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
dependency "sg_dc" {
    config_path = find_in_parent_folders("sg/dc")
}
dependency "sg_egress-all" {
    config_path = find_in_parent_folders("sg/egress-all")
}

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

locals {
  tags = {
    "business:product-owner" = "oleksandr.kulesh@raiffeisen.ua",
    "business:emergency-contact" = "oleksandr.kulesh@raiffeisen.ua",
    "platform:backup" = "Daily-3day-Retention"
  }
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags, local.tags)

  name = basename(get_terragrunt_dir())
  domain = "pnp.rbua"
}

inputs = {
    name          = "${local.name}.${local.domain}"
    ami           = "ami-0d030edc442a8c188"
    instance_type = "t3a.xlarge" #"c6a.xlarge"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[1]
    key_name      = "ad-default-pem"
    tags          = local.tags_map
    root_block_device        = [{ volume_size = "50", volume_type = "gp3" }]
    
    create_iam_role_ssm = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,
        dependency.sg_dc.outputs.security_group_id,
    ]
}