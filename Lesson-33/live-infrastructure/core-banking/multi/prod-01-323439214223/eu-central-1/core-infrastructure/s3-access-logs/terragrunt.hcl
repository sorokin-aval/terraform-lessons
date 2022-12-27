include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
  name         = "cbs-access-logs-${local.account_vars.locals.aws_account_id}"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.0.1"
}

inputs = {
  bucket                                = local.name
  acl                                   = "log-delivery-write"
  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  versioning = {
    enabled = false
  }
  tags = local.tags_map
}