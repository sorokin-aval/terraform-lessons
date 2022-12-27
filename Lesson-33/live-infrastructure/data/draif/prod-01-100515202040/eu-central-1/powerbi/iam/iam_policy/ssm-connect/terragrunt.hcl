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
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  region         = local.region_vars.locals.aws_region
}


inputs = {
  name        = "${local.project_vars.locals.resource_prefix}-ssm"
  path        = "/"
  description = "${local.project_vars.locals.resource_prefix}-ssm policy. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "arn:aws:kms:eu-central-1:${local.aws_account_id}:key/82f99d5e-c28f-415d-ad10-bbd6b0ca30dc"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateDataChannel",
                "s3:GetEncryptionConfiguration",
                "ssm:GetConnectionStatus",
                "ec2:DescribeInstances",
                "ssm:DescribeInstanceInformation",
                "ssm:DescribeSessions",
                "ssmmessages:OpenDataChannel",
                "ssm-guiconnect:*",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:CreateControlChannel",
                "ssm:GetInventorySchema",
                "ssm:DescribeInstanceProperties"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": "ssm:StartSession",
            "Resource": [
                "arn:aws:ssm:eu-central-1:${local.aws_account_id}:document/SSM-SessionManagerRunShell",
                "arn:aws:ssm:eu-central-1:*:document/AWS-StartPortForwardingSession"
            ],
            "Condition": {
                "BoolIfExists": {
                    "ssm:SessionDocumentAccessCheck": "true"
                }
            }
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": "ssm:StartSession",
            "Resource": [
                "arn:aws:ssm:*:${local.aws_account_id}:managed-instance/*",
                "arn:aws:ec2:*:${local.aws_account_id}:instance/*"
                ],
            "Condition": {
                "BoolIfExists": {
                    "ssm:SessionDocumentAccessCheck": "true"
                },
                "StringLike": {
                    "ssm:resourceTag/Project": [
                        "powerbi"
                    ]
                }
            }
        }
    ]
}

EOF

  tags = local.tags_map

}
