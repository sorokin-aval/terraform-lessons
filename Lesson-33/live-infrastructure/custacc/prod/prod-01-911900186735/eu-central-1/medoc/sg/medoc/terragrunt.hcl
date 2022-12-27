#custacc
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  #  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//terraform-aws-security-group?ref=main"
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  #  source = local.account_vars.sources_sg
}

locals {
  #    common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
  #    name         = "launch-wizard-1"
}


inputs = {
  use_name_prefix = false
  name            = local.name
  description     = "Security group for MEDOC"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags = merge(local.app_vars.locals.tags, {
  map-migrated = "d-server-00qype0w820fhs" })

  ingress_with_cidr_blocks = [
    {
      name        = "POOLMEDOC-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-MEDOC sg_rule inbound"
      cidr_blocks = "10.190.128.0/23"
    },
    {
      name        = "POOLHODIR-40-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-HO-DIR(40) sg_rule inbound"
      cidr_blocks = "10.190.40.0/23"
    },
    {
      name        = "POOLHODIR-42-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-HO-DIR(42) sg_rule inbound"
      cidr_blocks = "10.190.42.0/23"
    },
    {
      name        = "POOLHODIR-44-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-HO-DIR(44) sg_rule inbound"
      cidr_blocks = "10.190.44.0/23"
    },
    {
      name        = "POOLHODIR-46-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-HO-DIR(46) sg_rule inbound"
      cidr_blocks = "10.190.46.0/23"
    },
    {
      name        = "POOLOPC10-56-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-OPC10(56) sg_rule inbound"
      cidr_blocks = "10.190.56.0/22"
    },
    {
      name        = "POOLOPC10-114-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "HO-POOL-OPC10(114) sg_rule inbound"
      cidr_blocks = "10.190.114.0/23"
    },
    {
      name        = "AWS-INT-AB-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "AWS-INT-AB-MEDOC sg_rule inbound"
      cidr_blocks = "10.226.138.0/24"
    },
    {
      name        = "AWS-TRN-A-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "AWS-TRN-A-MEDOC sg_rule inbound"
      cidr_blocks = "10.226.139.160/27"
    },
    {
      name        = "AWS-TRN-B-MEDOC"
      from_port   = 9996
      to_port     = 9996
      protocol    = "tcp"
      description = "AWS-TRN-B-MEDOC sg_rule inbound"
      cidr_blocks = "10.226.139.192/27"
    }
  ]
  egress_with_cidr_blocks = [
    {
      name        = "Gryada"
      from_port   = 3011
      to_port     = 3016
      protocol    = "tcp"
      description = "MEDOC - Gryada"
      cidr_blocks = "10.191.22.170/32"
    },
    # 10.225.102.26 10.225.103.173
    {
      name        = "SES25a"
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      description = "MEDOC - SES25"
      cidr_blocks = "10.225.102.26/32"
    },
    {
      name        = "SES25b"
      from_port   = 25
      to_port     = 25
      protocol    = "tcp"
      description = "MEDOC - SES25"
      cidr_blocks = "10.225.103.173/32"
    },
    {
      name        = "SES587a"
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "MEDOC - SES587"
      cidr_blocks = "10.225.102.26/32"
    },
    {
      name        = "SES587b"
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "MEDOC - SES587"
      cidr_blocks = "10.225.103.173/32"
    }
  ]
}