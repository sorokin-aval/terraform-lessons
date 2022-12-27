locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = "${basename(dirname(find_in_parent_folders("s3-access-log")))}-access-logs-${local.account_vars.locals.aws_account_id}"
}

terraform {
  source = local.account_vars.locals.sources["aws-s3-bucket"]
}

inputs = {
  bucket = local.name
  acl    = "log-delivery-write"

  attach_elb_log_delivery_policy = true

  versioning = {
    enabled = false
  }

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-020b2954batpyz" }
  )
}
