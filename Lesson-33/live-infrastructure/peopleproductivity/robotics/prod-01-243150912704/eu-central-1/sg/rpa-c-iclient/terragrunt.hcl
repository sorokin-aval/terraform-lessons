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
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags)

  name = basename(get_terragrunt_dir())
}

inputs = {
  name = local.name
  description = "security group rpa-clients"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  # egress_with_cidr_blocks = [
  #   {
  #     "cidr_blocks"="0.0.0.0/0"
  #     "protocol"= "-1"
  #     "from_port"= 0
  #     "to_port"= 0
  #   }
  # ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 135
      "to_port"= 135
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 80
      "to_port"= 80
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 8001
      "to_port"= 8001
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 8181
      "to_port"=  8181
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "udp"
      "from_port"= 8181
      "to_port"= 8181
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 8199
      "to_port"= 8199
    },
    {
      "cidr_blocks"="10.0.0.0/8"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 445
      "to_port"= 445
    }

  ]

}