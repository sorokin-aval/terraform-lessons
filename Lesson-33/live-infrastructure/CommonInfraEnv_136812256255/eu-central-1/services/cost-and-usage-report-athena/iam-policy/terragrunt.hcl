include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v4.18.0"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  tags_map = local.common_tags.locals.common_tags

  # Extract out exact variables for reuse
  resource_prefix           = "cost-and-usage-report-athena"
  database_name             = "athenacurcfn_costand_usage_report_daily_athena"
  bucket_name               = "rbua-cur-bucket"
  query_results_bucket_name = "athena-query-results-136812256255"

  aws_account_id = local.account_vars.locals.aws_account_id
  region         = local.region_vars.locals.aws_region

}


inputs = {
  name        = "${local.resource_prefix}-policy"
  path        = "/"
  description = "${local.resource_prefix}-policy. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "athena:ListEngineVersions",
                "athena:ListWorkGroups",
                "athena:ListDataCatalogs",
                "athena:ListDatabases",
                "athena:GetDatabase",
                "athena:ListTableMetadata",
                "athena:GetTableMetadata"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ReadOnlyAccessForAllKMSKeysInAccount",
            "Effect": "Allow",
            "Action": [
                "kms:GetPublicKey",        
                "kms:GetKeyRotationStatus",
                "kms:GetKeyPolicy",
                "kms:DescribeKey",
                "kms:ListKeyPolicies",
                "kms:ListResourceTags",
                "tag:GetResources",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:eu-central-1:136812256255:key/6574cc58-c7e1-4791-9423-6cdc6edcd364"
            ]
        },
        {
            "Sid": "ReadOnlyAccessForOperationsWithNoKMSKey",
            "Effect": "Allow",
            "Action": [
                "kms:ListKeys",
                "kms:ListAliases",
                "iam:ListRoles",
                "iam:ListUsers"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "athena:GetWorkGroup", 
                "athena:BatchGetQueryExecution",
                "athena:GetQueryExecution",
                "athena:ListQueryExecutions",
                "athena:StartQueryExecution",
                "athena:StopQueryExecution",
                "athena:GetQueryResults",
                "athena:GetQueryResultsStream",
                "athena:CreateNamedQuery",
                "athena:GetNamedQuery",
                "athena:BatchGetNamedQuery",
                "athena:ListNamedQueries",
                "athena:DeleteNamedQuery",
                "athena:CreatePreparedStatement",
                "athena:GetPreparedStatement",
                "athena:ListPreparedStatements",
                "athena:UpdatePreparedStatement",
                "athena:DeletePreparedStatement"
            ],
            "Resource": [
                "arn:aws:athena:${local.region}:${local.aws_account_id}:workgroup/primary"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:GetTable",
                "glue:GetTables",
                "glue:GetTableVersions",
                "glue:SearchTables",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:GetPartitions"
            ],
            "Resource": [
                "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:database/${local.database_name}",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:table/${local.database_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketPolicy",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketVersioning",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:PutObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketPolicy",
                "s3:GetEncryptionConfiguration",
                "s3:GetBucketVersioning",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.query_results_bucket_name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:PutObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.query_results_bucket_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}

EOF

  tags = local.tags_map

}
