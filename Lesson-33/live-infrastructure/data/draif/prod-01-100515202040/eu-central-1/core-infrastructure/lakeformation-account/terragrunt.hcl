include "root" {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags

  resource_prefix = "${local.project_vars.locals.resource_prefix}-lakeformation"
  aws_account_id  = local.project_vars.locals.account_vars.locals.aws_account_id
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-lakeformation.git//modules/lakeformation-account?ref=lakeformation_v0.2.1"
}

inputs = {
  # TODO: use dependency for main roles instead of hardcode
  lf_admin_arns = [
    "arn:aws:iam::100515202040:role/Admin", "arn:aws:iam::100515202040:role/rbua-data-prod-terraform",
    "arn:aws:iam::100515202040:role/terraform-role", "arn:aws:iam::100515202040:role/rbua-data-prod-data-engineer"
  ]
  kms_policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.aws_account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.aws_account_id}:role/Admin"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  resource_prefix = local.resource_prefix
  tags            = local.tags_map
}
