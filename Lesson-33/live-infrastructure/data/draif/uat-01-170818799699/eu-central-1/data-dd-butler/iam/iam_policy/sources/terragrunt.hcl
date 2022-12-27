include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
  layer        = "raw"
  s3_prefix    = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}"
}


inputs = {
  name        = "${local.tags_map.Nwu}-${local.tags_map.Tech_domain}-sources"
  path        = "/"
  description = "${local.tags_map.Project}-sources policy. Created with Terragrunt. Used to grant access to sources for project"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "01getsources",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.rba_links/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_acc_info/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_cards/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_accounts/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_clients/*",
                "arn:aws:s3:::${local.s3_prefix}-riskdata/ods/mrb.tm_products_mapping/*",
                "arn:aws:s3:::${local.s3_prefix}-bankmaster/ods/cas.ca0201account/*",
                "arn:aws:s3:::${local.s3_prefix}-int/ods/iq.audit_event/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/app_own.mcc_codes/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/app_own.merchants/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.profile_person/*",
                "arn:aws:s3:::${local.s3_prefix}-riskdata/ods/rdm.wl_offers/*"
            ]
        },
        {
            "Sid": "02listsources",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_prefix}-cmd",
                "arn:aws:s3:::${local.s3_prefix}-transmaster",
                "arn:aws:s3:::${local.s3_prefix}-riskdata",
                "arn:aws:s3:::${local.s3_prefix}-bankmaster",
                "arn:aws:s3:::${local.s3_prefix}-int",
                "arn:aws:s3:::${local.s3_prefix}-cmd"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
