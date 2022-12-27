include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

dependency "vpc" {
  config_path = "../../../../core-infrastructure/imported-vpc/"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map = local.common_tags.locals
  name = "psi.noc-dc1.kv.aval"
}

inputs = {
    name  = local.name
    ami           = "ami-065202aa414083d57" // Imported from on-prem as is
    instance_type = "t3a.medium"
    ebs_optimized = true
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
    key_name = "avalaunch-common"
    tags = local.tags_map
    volume_tags = local.tags_map

    sg_ingress_rules = [
        {
            from_port   = 10389
            to_port     = 10389
            protocol    = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            from_port   = 10636
            to_port     = 10636
            protocol    = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            from_port   = 22
            to_port     = 22
            protocol    = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
    sg_egress_rules = [
        {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
}