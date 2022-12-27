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
  project_vars       = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars       = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars        = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map         = local.source_vars.locals
  tags_map           = local.project_vars.locals.project_tags
  aws_account_id     = local.account_vars.locals.aws_account_id
  project_name       = split("${local.tags_map.Domain}-", local.tags_map.Project)[1]
  layer              = "integration"
  s3_prefix          = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}"
  #TODO: hardcode - think how to define it at global level and set cross account access
  data_account_id    = 100515202040
  project_kms_key_id = "38e738e4-ad4d-4964-8ba4-888e91434ecd"
}


inputs = {
  name        = "${local.tags_map.Nwu}-${local.tags_map.Tech_domain}-s3"
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt. Used by team to store project files"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ProjectBucket",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:PutObject*",
                "s3:DeleteObject*",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_prefix}-${local.project_name}/*",
                "arn:aws:s3:::${local.s3_prefix}-${local.project_name}"
            ]
        },{
    "Sid": "AllowUseOfKeyInAccount${local.data_account_id}",
    "Effect": "Allow",
    "Action": [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ],
    "Resource": "arn:aws:kms:eu-central-1:${local.data_account_id}:key/${local.project_kms_key_id}"
}
    ]
}
EOF

  tags = local.tags_map

}
