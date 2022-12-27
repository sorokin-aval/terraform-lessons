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
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  region         = local.region_vars.locals.aws_region
  kms_key_id     = "89073488-6f7c-4d72-98e6-e40edf2d85b2"
}


inputs = {
  name        = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-ec2"
  path        = "/"
  description = "${local.tags_map.Project}-sources policy. Created with Terragrunt. Used to grant start/stop/reboot ec2 permissions"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Project": "${local.tags_map.Project}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeInstanceProperties",
                "ssm:Describe*",
                "ec2:describeInstances",
                "ec2:Describe*",
                "ec2:CreateTags",
                "ssm:GetConnectionStatus"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": [
                "arn:aws:ec2:${local.region}:${local.aws_account_id}:instance/*"
            ],
            "Condition": {
                "StringEquals": {
                    "ssm:resourceTag/Project": [
                        "${local.tags_map.Project}"
                    ]
                }
            }
        },
        {
            "Effect": "Deny",
            "Action": "ec2:TerminateInstances",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Project": "${local.tags_map.Project}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": ["arn:aws:kms:${local.region}:${local.aws_account_id}:key/${local.kms_key_id}"]
        }
    ]
}
EOF

  tags = local.tags_map

}
