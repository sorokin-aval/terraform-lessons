include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info") 
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map      = merge(local.common_tags.locals)

  name = basename(get_terragrunt_dir())
}

inputs = {
  name = local.name
  description = "security group for ${local.name} server"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.227.36.135/32"
      "description"= "From rlua-app.ms.aval"
      "protocol"= "tcp"
      "from_port"= 1435
      "to_port"= 1435
    },
    {
      "cidr_blocks"="10.227.36.135/32"
      "description"= "From rlua-app.ms.aval"
      "protocol"= "tcp"
      "from_port"= 1440
      "to_port"= 1440
    },
    {
      "cidr_blocks"="10.227.36.135/32"
      "description"= "From rlua-app.ms.aval"
      "protocol"= "udp"
      "from_port"= 1434
      "to_port"= 1434
    },
    {
      "cidr_blocks"="10.227.36.135/32"
      "description"= "From rlua-app.ms.aval"
      "protocol"= "tcp"
      "from_port"= 443
      "to_port"= 443
    }
  ]

}