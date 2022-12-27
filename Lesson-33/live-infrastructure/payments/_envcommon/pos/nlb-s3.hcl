locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "${basename(dirname(find_in_parent_folders("s3-access-log")))}-access-logs-${local.account_vars.locals.aws_account_id}"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.0.1"
}

inputs = {
  bucket = local.name
  acl    = "log-delivery-write"

  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true

  versioning = {
    enabled = false
  }

  tags = local.app_vars.locals.tags
}
