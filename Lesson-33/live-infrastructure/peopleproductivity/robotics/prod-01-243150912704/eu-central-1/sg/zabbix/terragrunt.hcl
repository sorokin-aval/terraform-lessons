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
  name = "zabbix"
  description = "security group for monitoring service"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  egress_with_cidr_blocks = [
  {
      "cidr_blocks"="10.225.109.0/24"
      "description"= "To zabbix server for monotoring"
      "protocol"= "tcp"
      "from_port"= 10051
      "to_port"= 10051
    },
    {
      "cidr_blocks"="10.225.102.0/24"
      "description"= "To zabbix server for monotoring"
      "protocol"= "tcp"
      "from_port"= 10051
      "to_port"= 10051
    },
    {
      "cidr_blocks"="10.225.102.104/32"
      "description"= "To zabbix server for monotoring"
      "protocol"= "tcp"
      "from_port"= 0
      "to_port"= 65535
    }  
  ]

  ingress_with_cidr_blocks = [
    {
      "cidr_blocks"="10.225.109.0/24"
      "description"= "From zabbix server for monotoring"
      "protocol"= "tcp"
      "from_port"= 10050
      "to_port"= 10050
    },
    {
      "cidr_blocks"="10.225.102.0/24"
      "description"= "From zabbix server for monotoring"
      "protocol"= "tcp"
      "from_port"= 10050
      "to_port"= 10050
    },
    {
      "cidr_blocks"="10.225.109.0/24"
      "description"= "From zabbix server for monotoring"
      "protocol"= "icmp"
      "from_port"= -1
      "to_port"= -1
    },
    {
      "cidr_blocks"="10.225.102.0/24"
      "description"= "From zabbix server for monotoring"
      "protocol"= "icmp"
      "from_port"= -1
      "to_port"= -1
    },
    {
      "cidr_blocks"="10.225.102.104/32"
      "description"= "nagios-t-c.omon.kv.aval"
      "protocol"= "tcp"
      "from_port"= 1521
      "to_port"= 1521
    }
  ]

}
