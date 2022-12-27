include {
  path = find_in_parent_folders()
}

# Hardcode!
dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}
iam_role = local.account_vars.iam_role
locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  name        = "CelerMon"
  description = "security group for celer monitoring server"

  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  tags_map        = merge(local.common_tags_map)

}

inputs = {
  name            = local.name
  use_name_prefix = false
  description     = local.description
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.tags_map

  egress_with_cidr_blocks = [
    {
      "cidr_blocks" = "0.0.0.0/0"
      "from_port"   = 0
      "protocol"    = "-1"
      "to_port"     = 0
    }
  ]

  ingress_with_cidr_blocks = [
              {
                "cidr_blocks"="0.0.0.0/0"
                "description"= ""
                "from_port"= 3389
                "protocol"= "tcp"
                "to_port"= 3389
              },
              {
                "cidr_blocks"="10.191.242.32/28"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },
              {
                "cidr_blocks"="10.191.248.0/23"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },
              {
                "cidr_blocks"="10.190.124.192/26"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },
              {
                "cidr_blocks"="10.190.131.96/27"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.190.51.128/26"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.190.247.0/24"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.191.208.0/20"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.190.50.32/27"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.185.96.0/24"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.190.40.0/21"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              },              
              {
                "cidr_blocks"="10.190.61.192/26"
                "description"= ""
                "from_port"= 9091
                "protocol"= "tcp"
                "to_port"= 9092
              }
            ]
}
