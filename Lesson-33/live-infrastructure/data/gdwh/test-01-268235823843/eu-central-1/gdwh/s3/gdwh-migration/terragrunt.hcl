include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}//"
}

locals {
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = merge(local.project_vars.locals.project_tags, { System = "${basename(get_terragrunt_dir())}" })
  aws_account_id = local.account_vars.locals.aws_account_id
  layer          = "backup"
  name           = "${basename(get_terragrunt_dir())}"
}

inputs = {
  bucket                                = lower("${local.tags_map.entity}-${local.tags_map.domain}-${local.tags_map["security:environment"]}-${local.layer}-${local.name}")
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true
  force_destroy                         = false
  request_payer                         = "Requester"
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  control_object_ownership              = true
  object_ownership                      = "BucketOwnerPreferred"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  intelligent_tiering = {
    default = {
      status  = "Enabled"
      tiering = {
        ARCHIVE_ACCESS = {
          days = 365
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 730
        }
      }
    }
  }

  versioning = {
    enabled = true
  }

  tags = local.tags_map

}
