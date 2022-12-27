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
  source_map = local.source_vars.locals
  tags_map   = local.project_vars.locals.project_tags
  layer      = "raw"
  s3_prefix  = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}"
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
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm.rcukru/*",
                "arn:aws:s3:::${local.s3_prefix}-b2/ods/creator.document_avl/*",
                "arn:aws:s3:::${local.s3_prefix}-bankmaster/ods/bmrs.rs2016deal/*",
                "arn:aws:s3:::${local.s3_prefix}-bankmaster/ods/udf.ud9302rd/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/rd_2022.dbo.lsb/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/rd_2022.dbo.rd/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.cln/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.ls/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.mfo/*"
            ]
        },
        {
            "Sid": "02listsources",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_prefix}-ataccama",
                "arn:aws:s3:::${local.s3_prefix}-b2",
                "arn:aws:s3:::${local.s3_prefix}-bankmaster",
                "arn:aws:s3:::${local.s3_prefix}-vicont"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
