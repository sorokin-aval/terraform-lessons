locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = "s3-cv-${local.account_vars.locals.aws_account_id}"
}

terraform {
  source = local.account_vars.locals.sources["aws-s3-bucket"]
}

inputs = {
  bucket = local.name
  acl    = "private"

  versioning = {
    enabled = false
  }

  tags = merge(local.account_vars.locals.tags,
               local.domain_vars.locals.common_tags,
               { map-migrated = "d-server-00sj1xhbfx35r4" })

}
