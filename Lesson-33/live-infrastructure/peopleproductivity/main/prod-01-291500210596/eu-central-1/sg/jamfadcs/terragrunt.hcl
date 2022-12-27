include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
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
  description = "security group for jamfadcs server - nlb"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map
 
  egress_with_cidr_blocks = [
    {
      "cidr_blocks"="100.100.49.48/28"
      "description"= "to NLB inet-faced Inet-In-PublicA"
      "protocol"= "tcp"
      "from_port"= 1024
      "to_port"= 65535
    },
    {
      "cidr_blocks"="100.100.49.64/28"
      "description"= "to NLB inet-faced Inet-In-PublicB"
      "protocol"= "tcp"
      "from_port"= 1024
      "to_port"= 65535
    }
  
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="100.100.49.48/28"
      "description"= "from NLB inet-faced Inet-In-PublicA"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    },
    {
      "cidr_blocks"="100.100.49.64/28"
      "description"= "from NLB inet-faced Inet-In-PublicB"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    }

  ]
  
}