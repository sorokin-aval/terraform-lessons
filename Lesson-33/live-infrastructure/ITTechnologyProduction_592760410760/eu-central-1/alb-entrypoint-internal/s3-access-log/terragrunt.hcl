include {
  path = find_in_parent_folders()
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map = local.common_tags.locals
  name      = "${local.common_tags.locals.Name}-access-logs-${local.account_vars.locals.aws_account_id}"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v2.15.0"
}

inputs = {
  bucket = local.name
  acl    = "log-delivery-write"
  attach_elb_log_delivery_policy  = true
  versioning = {
    enabled = false
  }
  tags = local.tags_map
}