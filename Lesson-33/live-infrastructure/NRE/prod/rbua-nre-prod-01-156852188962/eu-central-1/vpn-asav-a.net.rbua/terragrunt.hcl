## terragrunt.hcl
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}
include {
  path = find_in_parent_folders()
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git///?ref=vpc_id_ec2"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags_map     = local.common_tags.locals.default_tag
  name         = basename(get_terragrunt_dir())
}

inputs = {
  name                         = local.name
  #create                       = false
  source_dest_check            = false
  ami                          = "ami-078eeb71b761721b4"
  instance_type                = "c5.large"
  create_security_group_inline = false
  ebs_optimized                = true
  key_name                     = "rbua-asav-prod-vpn"
  vpc_id                       = "vpc-08b4a6f83c6f91f26"
  tags                         = merge(local.tags_map, {
    map-migrated               = "d-server-00hzzux57a8s5h",
    internet-faced             = "true"
  })
  network_interface            = [
    {
      device_index         = 0
      network_interface_id = "eni-0d7077738d13259bc"
    },
    {
      device_index         = 1
      network_interface_id = "eni-0d26d985643ab3933"
    }
  ]
}
