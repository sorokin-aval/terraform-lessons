include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc_info")
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {


  name = "ORACLE_DB"
  description = "security group for ORACLE DB"
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  #current_tags = read_terragrunt_config("tags.hcl")
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  #local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map)

}

inputs = {
  name = local.name
  description = local.description

  use_name_prefix = false
  vpc_id   = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
        {
                "cidr_blocks" = "0.0.0.0/0"
              
                "description" = "no limit"
                "from_port" = 0
                "protocol" = "-1"
                "to_port" = 0
   }
  ]

  ingress_with_cidr_blocks =  [
              {
  
               "cidr_blocks" = "0.0.0.0/0"
               
                "from_port" = 1521
                "protocol" = "tcp"
                "to_port" = 1526
              },
              {
                "cidr_blocks" = "0.0.0.0/0"
                "description" = ""
                "from_port" = 22
                "protocol" = "tcp"
                "to_port" = 22
              },
              {
               "cidr_blocks" = "0.0.0.0/0"
                "description" = "tls"
                "from_port" = 1575
                "protocol" = "tcp"
                "to_port" = 1575
              }

 ]


}
