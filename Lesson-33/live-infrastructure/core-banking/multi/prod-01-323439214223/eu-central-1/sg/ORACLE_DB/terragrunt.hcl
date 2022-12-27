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

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  name        = "ORACLE_DB"
  description = "security group for ORACLE DB"

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

      "cidr_blocks" = "0.0.0.0/0"

      "from_port" = 1521
      "protocol"  = "tcp"
      "to_port"   = 1526
    },
    {
      "cidr_blocks" = "0.0.0.0/0"
      "description" = ""
      "from_port"   = 22
      "protocol"    = "tcp"
      "to_port"     = 22
    },
    {
      "cidr_blocks" = "0.0.0.0/0"
      "description" = "tls"
      "from_port"   = 1575
      "protocol"    = "tcp"
      "to_port"     = 1575
    },

    {
      "cidr_blocks" = "10.191.2.184/32"
      "description" = "access for BigPoint (DC)"
      "from_port"   = 8400
      "protocol"    = "tcp"
      "to_port"     = 8400
    },
    {
      "cidr_blocks" = "10.191.2.184/32"
      "description" = "access for BigPoint (DC)"
      "from_port"   = 8403
      "protocol"    = "tcp"
      "to_port"     = 8403
    },

    {
      "cidr_blocks" = "10.226.114.0/25"
      "description" = "CEM-2135"
      "from_port"   = 1521
      "protocol"    = "tcp"
      "to_port"     = 1522
    },

    {
      "cidr_blocks" = "10.226.112.160/27"
      "description" = "CEM-2129"
      "from_port"   = 1521
      "protocol"    = "tcp"
      "to_port"     = 1526
    },
    {
      "cidr_blocks" = "10.226.112.160/27"
      "description" = "CEM-2129"
      "from_port"   = 1575
      "protocol"    = "tcp"
      "to_port"     = 1575
    },
    {
      "cidr_blocks" = "10.226.112.192/27"
      "description" = "CEM-2129"
      "from_port"   = 1521
      "protocol"    = "tcp"
      "to_port"     = 1526
    },
    {
      "cidr_blocks" = "10.226.112.192/27"
      "description" = "CEM-2129"
      "from_port"   = 1575
      "protocol"    = "tcp"
      "to_port"     = 1575
    },

    {
      "cidr_blocks" = "10.225.102.0/24"
      "description" = "CEM-2168"
      "from_port"   = 10050
      "protocol"    = "tcp"
      "to_port"     = 10050
    },
    {
      "cidr_blocks" = "10.225.103.0/24"
      "description" = "CEM-2168"
      "from_port"   = 10050
      "protocol"    = "tcp"
      "to_port"     = 10050
    },
    {
      "cidr_blocks" = "10.225.102.0/24"
      "description" = "CEM-2168"
      "from_port"   = 1521
      "protocol"    = "tcp"
      "to_port"     = 1521
    },
    {
      "cidr_blocks" = "10.225.103.0/24"
      "description" = "CEM-2168"
      "from_port"   = 1521
      "protocol"    = "tcp"
      "to_port"     = 1521
    },
    {
      "cidr_blocks" = "10.225.102.0/24"
      "description" = "CEM-2168"
      "protocol"    = "icmp"
      "from_port"   = 8
      "to_port"     = 0
    },
    {
      "cidr_blocks" = "10.225.103.0/24"
      "description" = "CEM-2168"
      "protocol"    = "icmp"
      "from_port"   = 8
      "to_port"     = 0
    },

    {
      "cidr_blocks" = "10.191.12.30/32"
      "description" = "CEM-2175"
      "protocol"    = "tcp"
      "from_port"   = 1521
      "to_port"     = 1521
    },

    /*
	      {
                "cidr_blocks" = "10.226.40.147/32"
                "description" = "CEM-987"
                "from_port" = 1521
                "protocol" = "tcp"
                "to_port" = 1521
              },
              {
                "cidr_blocks" = "10.226.40.138/32"
                "description" = "CEM-987"
                "from_port" = 1521
                "protocol" = "tcp"
                "to_port" = 1521
              }
*/
  ]


}
