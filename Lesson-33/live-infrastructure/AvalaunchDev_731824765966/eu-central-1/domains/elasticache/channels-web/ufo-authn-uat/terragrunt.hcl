include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//elasticache?ref=elasticache_v1.0.1"
  
  # before_hook "before_hook" {
  #   commands = ["apply", "plan", "destroy"]
  #   execute  = ["bash", "-c", "read  -p 'VAULT_ADDR=' VAULT_ADDR && vault login -address=$VAULT_ADDR -method=ldap username=$USER"]
  # }
}


locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common tags for reuse
  tags_map = local.common_tags.locals
}

inputs = {
  subnets_names    = ["LZ-AVAL_AVALAUNCH_DEV-RestrictedB", "LZ-AVAL_AVALAUNCH_DEV-RestrictedA", "LZ-AVAL_AVALAUNCH_DEV-RestrictedC"]
  tags             = local.tags_map

  environment                = "uat"
  domain_name                = "channels-web"
  service_name               = "ufo-authn"

  instance_type              = "cache.m6g.large"
  
  cluster_size               = "2"
  automatic_failover_enabled = "true"
  multi_az_enabled           = "true"

  additional_security_group_rules = [
    {
      type              = "ingress"
      from_port         = 6379
      to_port           = 6379
      protocol          = "tcp"
      cidr_blocks       = ["100.124.48.0/22", "100.124.52.0/22", "100.124.56.0/22"]
    }
  ]
}