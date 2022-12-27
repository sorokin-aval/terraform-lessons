include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/vpc-endpoints.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg-ssm" {
  config_path = find_in_parent_folders("sg/ssm-vpc-endpoint")
}

inputs = {
  endpoints = {
    ec2messages = {
      service             = "ec2messages"
      security_group_ids  = [dependency.sg-ssm.outputs.security_group_id]
      subnet_ids          = dependency.vpc.outputs.lb_subnets.ids
      private_dns_enabled = true
      tags                = { Name = "ec2messages-vpc-endpoint" }
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
}
