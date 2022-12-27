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

  name        = basename(get_terragrunt_dir())
  description = "Security group for Amazon SES VPC endpoint"

  #current_tags = read_terragrunt_config("tags.hcl")
  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  #local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map)

}

inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.tags_map

  egress_with_cidr_blocks = [
    {
      "cidr_blocks" = "0.0.0.0/0"

      "description" = "no limit"
      "from_port"   = 0
      "protocol"    = "-1"
      "to_port"     = 0
    }
  ]

  ingress_with_cidr_blocks = [
    {

      "cidr_blocks" = "10.226.130.192/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalA"
      "from_port"   = 25
      "to_port"     = 25
    },
    {

      "cidr_blocks" = "10.226.131.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalB"
      "from_port"   = 25
      "to_port"     = 25
    },
    {

      "cidr_blocks" = "10.226.131.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalC"
      "from_port"   = 25
      "to_port"     = 25
    },

    {

      "cidr_blocks" = "10.226.130.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedA"
      "from_port"   = 25
      "to_port"     = 25
    },
    {

      "cidr_blocks" = "10.226.130.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedB"
      "from_port"   = 25
      "to_port"     = 25
    },
    {

      "cidr_blocks" = "10.226.130.128/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedC"
      "from_port"   = 25
      "to_port"     = 25
    },

    {

      "cidr_blocks" = "10.226.130.192/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalA"
      "from_port"   = 587
      "to_port"     = 587
    },
    {

      "cidr_blocks" = "10.226.131.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalB"
      "from_port"   = 587
      "to_port"     = 587
    },
    {

      "cidr_blocks" = "10.226.131.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalC"
      "from_port"   = 587
      "to_port"     = 587
    },

    {

      "cidr_blocks" = "10.226.130.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedA"
      "from_port"   = 587
      "to_port"     = 587
    },
    {

      "cidr_blocks" = "10.226.130.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedB"
      "from_port"   = 587
      "to_port"     = 587
    },
    {

      "cidr_blocks" = "10.226.130.128/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedC"
      "from_port"   = 587
      "to_port"     = 587
    },
    {

      "cidr_blocks" = "10.226.130.192/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalA"
      "from_port"   = 2587
      "to_port"     = 2587
    },
    {

      "cidr_blocks" = "10.226.131.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalB"
      "from_port"   = 2587
      "to_port"     = 2587
    },
    {

      "cidr_blocks" = "10.226.131.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalC"
      "from_port"   = 2587
      "to_port"     = 2587
    },

    {

      "cidr_blocks" = "10.226.130.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedA"
      "from_port"   = 2587
      "to_port"     = 2587
    },
    {

      "cidr_blocks" = "10.226.130.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedB"
      "from_port"   = 2587
      "to_port"     = 2587
    },
    {

      "cidr_blocks" = "10.226.130.128/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedC"
      "from_port"   = 2587
      "to_port"     = 2587
    },
    {

      "cidr_blocks" = "10.226.130.192/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalA"
      "from_port"   = 465
      "to_port"     = 465
    },
    {

      "cidr_blocks" = "10.226.131.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalB"
      "from_port"   = 465
      "to_port"     = 465
    },
    {

      "cidr_blocks" = "10.226.131.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalC"
      "from_port"   = 465
      "to_port"     = 465
    },

    {

      "cidr_blocks" = "10.226.130.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedA"
      "from_port"   = 465
      "to_port"     = 465
    },
    {

      "cidr_blocks" = "10.226.130.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedB"
      "from_port"   = 465
      "to_port"     = 465
    },
    {

      "cidr_blocks" = "10.226.130.128/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedC"
      "from_port"   = 465
      "to_port"     = 465
    },
    {

      "cidr_blocks" = "10.226.130.192/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalA"
      "from_port"   = 2465
      "to_port"     = 2465
    },
    {

      "cidr_blocks" = "10.226.131.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalB"
      "from_port"   = 2465
      "to_port"     = 2465
    },
    {

      "cidr_blocks" = "10.226.131.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-InternalC"
      "from_port"   = 2465
      "to_port"     = 2465
    },

    {

      "cidr_blocks" = "10.226.130.0/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedA"
      "from_port"   = 2465
      "to_port"     = 2465
    },
    {

      "cidr_blocks" = "10.226.130.64/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedB"
      "from_port"   = 2465
      "to_port"     = 2465
    },
    {

      "cidr_blocks" = "10.226.130.128/26"
      "protocol"    = "tcp"
      description   = "LZ-RBUA_CBS_PROD_01-RestrictedC"
      "from_port"   = 2465
      "to_port"     = 2465
    },

    /*
	      {
                "cidr_blocks" = "10.226.40.147/32"
                "description" = "CEM-987"
                "from_port" = 1521
                "protocol" = "tcp"
                "to_port" = 1521
              },
*/
  ]


}
