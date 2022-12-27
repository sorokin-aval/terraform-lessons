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
  description = "security group for hr-iis server"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
  
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.226.149.50/32"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 8822
      "to_port"= 8822
    },
    {
      "cidr_blocks"="0.0.0.0/0"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 1024
      "to_port"= 65535
    },
    {
      "cidr_blocks"="10.226.149.50/32"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 445
      "to_port"= 445
    },
    {
      "cidr_blocks"="10.226.149.50/32"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    },
    {
      "cidr_blocks"="10.191.208.0/20"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    },
    {
      "cidr_blocks"="10.191.248.0/23"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    },
    {
      "cidr_blocks"="10.190.247.0/24"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    },
    {
      "cidr_blocks"="10.191.208.0/20"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 8443
      "to_port"= 8443
    },
    {
      "cidr_blocks"="10.191.248.0/23"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 8443
      "to_port"= 8443
    },
    {
      "cidr_blocks"="10.190.247.0/24"
      "description"= "from hr-app server"
      "protocol"= "tcp"
      "from_port"= 8443
      "to_port"= 8443
    }
  ]
  egress_with_cidr_blocks = [
    {
      "cidr_blocks"="0.0.0.0/0"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    }
]
}