dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg-ses" {
  config_path = find_in_parent_folders("sg/smtp-vpc-endpoint")
}

dependency "sg-ssm" {
  config_path = find_in_parent_folders("sg/ssm-vpc-endpoint")
}

dependencies {
  paths = [
    find_in_parent_folders("sg/ssm-vpc-endpoint"),
    find_in_parent_folders("sg/smtp-vpc-endpoint"),
  ]
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id.id

  endpoints = {
    email-smtp = {
      service             = "email-smtp"
      security_group_ids  = [dependency.sg-ses.outputs.security_group_id]
      subnet_ids          = dependency.vpc.outputs.lb_subnets.ids
      private_dns_enabled = true
      tags                = { Name = "smtp-vpc-endpoint" }
    },
    smm = {
      service             = "ssm"
      security_group_ids  = [dependency.sg-ssm.outputs.security_group_id]
      subnet_ids          = dependency.vpc.outputs.lb_subnets.ids
      private_dns_enabled = true
      tags                = { Name = "ssm-vpc-endpoint" }
    },
    ssmmessages = {
      service             = "ssmmessages"
      security_group_ids  = [dependency.sg-ssm.outputs.security_group_id]
      subnet_ids          = dependency.vpc.outputs.lb_subnets.ids
      private_dns_enabled = true
      tags                = { Name = "ssmmessages-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      security_group_ids  = [dependency.sg-ssm.outputs.security_group_id]
      subnet_ids          = dependency.vpc.outputs.lb_subnets.ids
      private_dns_enabled = true
      tags                = { Name = "kms-vpc-endpoint" }
    },
  }

  tags = local.account_vars.locals.tags
}
