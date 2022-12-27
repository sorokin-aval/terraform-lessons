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
    ataccama = {
      bucket = "${local.s3_prefix}-ataccama"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    b2 = {
      bucket = "${local.s3_prefix}-b2"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    bankmaster = {
      bucket = "${local.s3_prefix}-bankmaster"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    bifit = {
      bucket = "${local.s3_prefix}-bifit"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    calc = {
      bucket = "${local.s3_prefix}-calc"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    cisaod = {
      bucket = "${local.s3_prefix}-cisaod"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    clc = {
      bucket = "${local.s3_prefix}-clc"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    cmd = {
      bucket = "${local.s3_prefix}-cmd"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    cms = {
      bucket = "${local.s3_prefix}-cms"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    cs360 = {
      bucket = "${local.s3_prefix}-cs360"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    datamarts-loans = {
      bucket = "${local.s3_prefix}-datamarts-loans"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    dms = {
      bucket = "${local.s3_prefix}-dms"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    dpd = {
      bucket = "${local.s3_prefix}-dpd"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    gdpr = {
      bucket = "${local.s3_prefix}-gdpr"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    gdwh = {
      bucket = "${local.s3_prefix}-gdwh"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    inex = {
      bucket = "${local.s3_prefix}-inex"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    int = {
      bucket = "${local.s3_prefix}-int"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    irbis = {
      bucket = "${local.s3_prefix}-irbis"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    iscard = {
      bucket = "${local.s3_prefix}-iscard"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    leis = {
      bucket = "${local.s3_prefix}-leis"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    norkom = {
      bucket = "${local.s3_prefix}-norkom"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    orion = {
      bucket = "${local.s3_prefix}-orion"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    pte = {
      bucket = "${local.s3_prefix}-pte"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    retailrep = {
      bucket = "${local.s3_prefix}-retailrep"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    rinfo = {
      bucket = "${local.s3_prefix}-rinfo"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    riskdata = {
      bucket = "${local.s3_prefix}-riskdata"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    salesbase = {
      bucket = "${local.s3_prefix}-salesbase"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    sfincs = {
      bucket = "${local.s3_prefix}-sfincs"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    sft = {
      bucket = "${local.s3_prefix}-sft"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    transmaster = {
      bucket = "${local.s3_prefix}-transmaster"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    ugam = {
      bucket = "${local.s3_prefix}-ugam"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    upc = {
      bucket = "${local.s3_prefix}-upc"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    vicont = {
      bucket = "${local.s3_prefix}-vicont"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    bass = {
      bucket = "${local.s3_prefix}-bass"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    avalexpress = {
      bucket = "${local.s3_prefix}-avalexpress"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    intrade = {
      bucket = "${local.s3_prefix}-intrade"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" })
    }
    westernunion = {
      bucket = "${local.s3_prefix}-westernunion"
      tags   = merge(local.tags_map, { ITOwner01 = "oleksandr.holubenko@raiffeisen.ua" }, { Tag = "TEMP" })
    }
  }
}
