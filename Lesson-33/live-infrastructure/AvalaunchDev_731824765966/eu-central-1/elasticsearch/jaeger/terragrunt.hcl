include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//elasticsearch?ref=elasticsearch_v1.0.0"
}

locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("../tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common tags for reuse
  tags_map = local.common_tags.locals
}

inputs = {
  domain_name                     = "jaeger"
  elasticsearch_version           = "7.7"
  dedicated_master_enabled        = false
  instance_count                  = 3
  instance_type                   = "r4.xlarge.elasticsearch"
  zone_awareness_enabled          = true
  az_count                        = 3
  ebs_enabled                     = true
  volume_size                     = 500
  allow_explicit_index            = true
  create_service_link_role        = true
  security_options_enabled        = true
  internal_user_database_enabled  = true
  master_user_username            = "jaeger"
  create_random_master_password   = true
  encrypt_at_rest_enabled         = true
  node_to_node_encryption_enabled = true
  snapshot_start_hour             = 23
  vpc_subnet_ids                  = ["subnet-0fb53caa7753833db", "subnet-05988ff4a31b186c6", "subnet-018379022dc8eba7e"]
  tags                            = local.tags_map
  cidr_blocks                     = ["100.124.48.0/22", "100.124.52.0/22", "100.124.56.0/22"]
  enforce_https                   = true
}
