include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
  layer        = "${basename(get_terragrunt_dir())}"
  s3_prefix    = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}"
}

inputs = {
  defaults = {
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
    lifecycle_rule = [
      {
        id                                     = "default"
        enabled                                = true
        abort_incomplete_multipart_upload_days = 1

        noncurrent_version_transition = [
          {
            days          = 30
            newer_noncurrent_versions = 3
            storage_class = "STANDARD_IA"
          }
        ]

        noncurrent_version_expiration = {
          days = 35
        }
      }
    ]

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

  }

  items = {
    b2 = {
      bucket = "${local.s3_prefix}-b2"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
  }
}
