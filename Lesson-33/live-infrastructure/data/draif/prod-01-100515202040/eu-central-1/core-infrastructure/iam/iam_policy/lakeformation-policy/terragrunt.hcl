include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  source_vars = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map   = local.common_tags.locals

  policy_name = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${basename(get_terragrunt_dir())}"
}


inputs = {
  name        = local.policy_name
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Sid": "LakeFormationDataAccessPermissionsForS3",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::rbua-data-prod-raw-*/*",
                "arn:aws:s3:::rbua-data-prod-integration-*/*"
            ]
        },
        {
            "Sid": "LakeFormationDataAccessPermissionsForS3ListBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::rbua-data-prod-raw-*",
                "arn:aws:s3:::rbua-data-prod-integration-*"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
