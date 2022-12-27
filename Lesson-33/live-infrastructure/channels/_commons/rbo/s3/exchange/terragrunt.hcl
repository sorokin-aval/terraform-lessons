locals {
  name         = "${basename(get_terragrunt_dir())}-${local.account_vars.aws_account_id}"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags         = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_front })
}

terraform {
  source = local.account_vars.sources_s3_bucket
}

iam_role = local.account_vars.iam_role

inputs = {
  bucket = local.name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning = {
    enabled = false
  }

  tags = local.tags
}
