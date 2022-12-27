terraform {
  source = local.account_vars.locals.sources["sg"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

locals {
  account_vars              = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                  = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  ip                        = [ "10.191.5.178/32", "10.185.214.232/32", "10.185.215.70/32", "10.185.215.71/32", "10.185.214.8/32", "10.190.51.0/26", "10.190.131.192/26" ]
}


inputs = {
  name                      = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${basename(get_terragrunt_dir())}"
  use_name_prefix           = false
  description               = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${title(basename(get_terragrunt_dir()))} for DMS-admins"
  vpc_id                    = dependency.vpc.outputs.vpc_id.id
  tags                      = local.tags_map.locals.tags

  ingress_cidr_blocks       = local.ip
  ingress_with_cidr_blocks  = [
      {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
    },
    {
      from_port   = 1489
      to_port     = 1489
      protocol    = "tcp"
      description = "Docbroker"
    },
    {
      from_port   = 1589
      to_port     = 1589
      protocol    = "tcp"
      description = "Docbroker_2"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "RDP"
    },
    {
      from_port   = 6000
      to_port     = 6009
      protocol    = "tcp"
      description = "GGPO"
    },
    {
      from_port   = 8080
      to_port     = 8089
      protocol    = "tcp"
      description = "HTTP"
    },
    {
      from_port   = 9043
      to_port     = 9043
      protocol    = "tcp"
      description = "EMC2"
    },
    {
      from_port   = 9060
      to_port     = 9060
      protocol    = "tcp"
      description = "Check_1"
    },
    {
      from_port   = 9080
      to_port     = 9100
      protocol    = "tcp"
      description = "API+Web"
    },
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      description = "Check_2"
    },
    {
      from_port   = 9220
      to_port     = 9220
      protocol    = "tcp"
      description = "Check_3"
    },
    {
      from_port   = 9443
      to_port     = 9468
      protocol    = "tcp"
      description = "Balancer"
    },
    {
      from_port   = 9990
      to_port     = 9999
      protocol    = "tcp"
      description = "Jboss console port"
    },
    {
      from_port   = 10000
      to_port     = 10100
      protocol    = "tcp"
      description = "Web+Content_1"
    },
    {
      from_port   = 15961
      to_port     = 15962
      protocol    = "tcp"
      description = "Web+Content_2"
    },
    {
      from_port   = 16961
      to_port     = 16962
      protocol    = "tcp"
      description = "Web+Content_3"
    },
    {
      from_port   = 25961
      to_port     = 25965
      protocol    = "tcp"
      description = "Web+Content_4"
    }
  ]
}