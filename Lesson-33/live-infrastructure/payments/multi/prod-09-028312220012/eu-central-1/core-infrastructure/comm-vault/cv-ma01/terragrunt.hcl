include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/cv-ma01.hcl")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  domain      = "${local.account_vars.locals.core_subdomain}.${local.account_vars.locals.domain}"
  hosted_zone = "${local.account_vars.locals.core_subdomain}.${local.account_vars.locals.domain}"

  block_device_encrypted = false
  ebs_optimized          = false

  ingress = [
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db_subnet_cidr_blocks" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db_subnet_cidr_blocks" },
    { from_port : 443, to_port : 443, protocol : "tcp", prefix_list_ids: ["pl-6ea54007"], description : "s3-endpoint" },
  ]
}
