include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

terraform {
  source = "."
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  #Tags in order ->(root folder)-> tags_common.hcl ->(current folder)-> tags.hcl
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags_common.hcl"))
  local_tags    = read_terragrunt_config("tags.hcl", {locals = {tags={}}})
  tags_map      = merge(local.common_tags.locals.tags, local.local_tags.locals.tags)

  name = basename(get_terragrunt_dir())
}
 
inputs = {
  name = local.name
  description = "security group for uadho-hpweb-c"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
  
  ]
 
  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "udp"
      "from_port"= 1433
      "to_port"= 1434
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 1438
      "to_port"= 1440
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 1433
      "to_port"= 1433
    }
  ]

}