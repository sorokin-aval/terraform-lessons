#custacc
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
#  config_path = "../../vpc-info/"
}
iam_role = local.account_vars.iam_role


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {

  name = basename(get_terragrunt_dir())
  description = "security group for test access"

   account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
   app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))




}

inputs = {
#  name = local.name
  name = "zabbix-agent-test"
  description = local.description

  use_name_prefix = false
  vpc_id   = dependency.vpc.outputs.vpc_id.id
#  tags = local.tags_map


  tags   = merge(local.app_vars.locals.tags, { 
  })


  ingress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = "10.225.102.0/23"
    },

    {
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      cidr_blocks = "10.225.102.0/23"
    }
  ]

  egress_with_cidr_blocks = [
        {
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      cidr_blocks = "10.225.102.0/23"
    }
  ]
}
