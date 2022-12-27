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
  name = "RDP"
  description = "security group for RDP only"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
    {
      "cidr_blocks"="0.0.0.0/0"
      "protocol"= "-1"
      "from_port"= 0
      "to_port"= 0
    }
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="0.0.0.0/0"
      "description"= ""
      "protocol"= "tcp"
      "from_port"= 3389
      "to_port"= 3389
    }
  ]

}