include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role


locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = "nlb-entrypoint-access-logs-${local.account_vars.locals.aws_account_id}"
  tags         = local.common_tags.locals

}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.4.0"
}

inputs = {
  bucket                         = local.name
  acl                            = "log-delivery-write"
  attach_elb_log_delivery_policy = true
  versioning = {
    enabled = false
  }
  tags = merge(local.tags, {
    Name = local.name
  })
}
