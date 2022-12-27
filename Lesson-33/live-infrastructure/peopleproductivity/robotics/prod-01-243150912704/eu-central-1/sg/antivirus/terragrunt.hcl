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
  name = "antivirus"
  description = "security group for antivirus service"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 8080
      "to_port"= 8081
    },
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 8444
      "to_port"= 8444
    }, 
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 65200
      "to_port"= 65200
    },
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 4343
      "to_port"= 4343
    },
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 8180
      "to_port"= 8180
    },
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"=443 
      "to_port"= 443
    }
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 8081
      "to_port"= 8081
    },
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "udp"
      "from_port"= 8082
      "to_port"= 8082
    },
    {
      "cidr_blocks"="10.226.113.0/24"
      "description"= "RBUA_CyberSecurity_General_Prod_04 (508566973729)"
      "protocol"= "tcp"
      "from_port"= 65200
      "to_port"= 65200
    }  
  ]

}