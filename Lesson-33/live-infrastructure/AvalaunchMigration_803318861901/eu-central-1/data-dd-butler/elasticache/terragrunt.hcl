include {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}


locals {
  project_vars         = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars         = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map             = local.project_vars.locals.project_tags
  name                 = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}"
  vault_path           = "secrets/service-internal-secrets/${local.tags_map.Environment}/${local.tags_map.Tech_domain}/elasticache/${local.tags_map.Project}"
  redis_database_name  = "${local.tags_map.Project}-redis"
  redis_engine_version = "6.2"
  redis_instance_type  = "cache.m6g.large"
  redis_cluster_size   = 1
  aws_account_id       = local.account_vars.locals.aws_account_id
  vault_address        = "https://vault.apps.${local.tags_map.Domain}.${local.tags_map.Nwu}"
  #TODO: rework when baseline implemented
  subnets_names        = [
    "LZ-AVAL_AVALAUNCH_DEV_MIG-RestrictedB", "LZ-AVAL_AVALAUNCH_DEV_MIG-RestrictedA",
    "LZ-AVAL_AVALAUNCH_DEV_MIG-RestrictedC"
  ]
  additional_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = ["100.124.64.0/22", "100.124.68.0/22", "100.124.72.0/22"]
    }
  ]
}
generate "provider_vault" {
  path      = "provider_vault.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "vault" {
    }
  EOF
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//elasticache?ref=elasticache_v1.0.3-beta"
}


inputs = {
  tags                            = local.tags_map
  redis_database_name             = local.redis_database_name
  instance_type                   = local.redis_instance_type
  cluster_size                    = local.redis_cluster_size
  domain_name                     = "None"
  service_name                    = "None"
  vault_path                      = local.vault_path
  subnets_names                   = local.subnets_names
  additional_security_group_rules = local.additional_security_group_rules
}
