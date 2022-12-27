include {
  path = find_in_parent_folders()
}

iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"
#iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-commvault-backup.git//?ref=commvault-media-agent_v1.0.1"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  name         = basename(get_terragrunt_dir())
}

inputs = {

  name          = local.name
  instance_type = "r5a.large"
  aws_ebs_volumes = { "index_volume" = { "device" = "/dev/xvdb", "size" = "5", "type" = "gp3" },
                      "ddb_volume" = { "device" = "/dev/xvdc", "size" = "10", "type" = "gp3" } }
  key_name = "dcre"

  tags        = merge(local.common_tags.locals.tags, { map-migrated = "d-server-01i0y2inoanfl9" })
  volume_tags = merge(local.common_tags.locals.tags, { map-migrated = "d-server-01i0y2inoanfl9" })
  s3_bucket_tags = merge(local.common_tags.locals.tags, { map-migrated = "d-server-00sj1xhbfx35r4" })

  sg_rules = [{ type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "SSH" },
    { type = "egress", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "SSH" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "Commvault MediaAgent" },
  { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "Commvault MediaAgent" }]

  enable_commvault_s3_policy_client = false
  enable_commvault_s3_policy_server = true

  s3_bucket_config = {
    "744770611513-01" = {
      "bucket"                  = "backup-commvault-744770611513"
      "block_public_acls"       = true
      "ignore_public_acls"      = true
      "block_public_policy"     = true
      "restrict_public_buckets" = true
      "object_lock_enabled"     = false
      "iam_role_arn"            = "arn:aws:iam::744770611513:role/cv-ma01-611513"
      "billing_tag"             = "Payments"
    },
    "744770611513-02" = {
      "bucket"                  = "backup-commvault-worm-744770611513"
      "block_public_acls"       = true
      "ignore_public_acls"      = true
      "block_public_policy"     = true
      "restrict_public_buckets" = true
      "object_lock_enabled"     = true
      "iam_role_arn"            = "arn:aws:iam::744770611513:role/cv-ma01-611513"
      "billing_tag"             = "Payments"
    },
    "744770611513-03" = {
      "bucket"                  = "backup-commvault-worm-02-744770611513"
      "block_public_acls"       = true
      "ignore_public_acls"      = true
      "block_public_policy"     = true
      "restrict_public_buckets" = true
      "object_lock_enabled"     = true
      "iam_role_arn"            = "arn:aws:iam::744770611513:role/cv-ma01-611513"
      "billing_tag"             = "Payments"
    },
      "744770611513-04" = {
      "bucket"                  = "backup-commvault-02-744770611513"
      "block_public_acls"       = true
      "ignore_public_acls"      = true
      "block_public_policy"     = true
      "restrict_public_buckets" = true
      "object_lock_enabled"     = false
      "iam_role_arn"            = "arn:aws:iam::744770611513:role/cv-ma01-611513"
      "billing_tag"             = "Payments"
    }    
  }
}
