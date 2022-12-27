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
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  region         = local.region_vars.locals.aws_region
  project_prefix  = local.project_vars.locals.project_prefix

#   # THERE IS NO PROJECT TAG
#   resource_prefix = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}"

}


inputs = {
  name        = "${local.project_prefix}-${basename(get_terragrunt_dir())}"
  path        = "/"
  description = "${local.project_prefix}-${basename(get_terragrunt_dir())} policy. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:CreateCrawler"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:GetDataCatalogEncryptionSettings",
                "glue:GetCatalogImportStatus"
            ],
            "Resource": [
                "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:UpdateCrawlerSchedule",
                "glue:UpdateCrawler",
                "glue:UntagResource",
                "glue:TagResource",
                "glue:StopCrawlerSchedule",
                "glue:StopCrawler",
                "glue:StartCrawlerSchedule",
                "glue:StartCrawler",
                "glue:DeleteCrawler",
                "glue:GetTags",
                "glue:GetCrawler",
                "glue:ListCrawls"
            ],
            "Resource": [
                "arn:aws:glue:${local.region}:${local.aws_account_id}:crawler/${local.project_prefix}-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "glue:UntagResource",
                "glue:ListCrawlers",
                "glue:GetSecurityConfiguration",
                "glue:GetSecurityConfigurations",
                "glue:GetCrawlers",
                "glue:GetCrawlerMetrics",
                "glue:GetClassifier",
                "glue:GetClassifiers",
                "glue:BatchGetCrawlers"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "WouldBeRemoved3",
            "Effect": "Allow",
            "Action": [
                "glue:UpdateDatabase",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:CreateDatabase",
                "glue:DeleteDatabase"
            ],
            "Resource": [
                "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:database/${local.project_prefix}-*",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:table/${local.project_prefix}-*/*",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:userDefinedFunction/${local.project_prefix}-*/*"
            ]
        },
        {
            "Sid": "WouldBeRemoved2",
            "Effect": "Allow",
            "Action": [
                "glue:GetTables",
                "glue:GetTable",
                "glue:DeleteTable",
                "glue:DeleteTableVersion",
                "glue:BatchDeleteTable",
                "glue:BatchDeleteTableVersion",
                "glue:SearchTables",
                "glue:GetTableVersions",
                "glue:GetPartitions"
            ],
            "Resource": [
                "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:database/${local.project_prefix}-*",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:table/${local.project_prefix}-*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lakeformation:StartTransaction",
                "lakeformation:CommitTransaction",
                "lakeformation:CancelTransaction",
                "lakeformation:ExtendTransaction",
                "lakeformation:DescribeTransaction",
                "lakeformation:ListTransactions",
                "lakeformation:GetTableObjects",
                "lakeformation:UpdateTableObjects",
                "lakeformation:DeleteObjectsOnCancel",
                "lakeformation:RegisterResource",
                "lakeformation:ListResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lakeformation:AddLFTagsToResource",
                "lakeformation:RemoveLFTagsFromResource",
                "lakeformation:GetResourceLFTags",
                "lakeformation:ListLFTags",
                "lakeformation:GetLFTag",
                "lakeformation:SearchTablesByLFTags",
                "lakeformation:SearchDatabasesByLFTags",
                "lakeformation:GrantPermissions",
                "lakeformation:RevokePermissions",
                "lakeformation:BatchGrantPermissions",
                "lakeformation:BatchRevokePermissions"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${local.aws_account_id}:role/AWSGlueServiceRole*",
                "arn:aws:iam::${local.aws_account_id}:role/${local.project_prefix}-glue-crawler",
                "arn:aws:iam::${local.aws_account_id}:role/${local.project_prefix}-lakeformation"
            ]
        },
        {
            "Sid": "WouldBeRemoved1",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::rbua-data-nifi-*/*",
                "arn:aws:s3:::${local.project_prefix}-raw-*/*",
                "arn:aws:s3:::${local.project_prefix}-powerbi/*",
                "arn:aws:s3:::${local.project_prefix}-integration-*/views/*",
                "arn:aws:s3:::${local.project_prefix}-integration-*/tables/*",
                "arn:aws:s3:::${local.project_prefix}-product-*/views/*",
                "arn:aws:s3:::${local.project_prefix}-product-*/tables/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListRoles",
                "iam:ListUsers",
                "s3:ListAllMyBuckets",
                "cloudwatch:GetMetricData",
                "cloudwatch:ListDashboards"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "WouldBeRemoved0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::rbua-data-nifi-*",
                "arn:aws:s3:::${local.project_prefix}-raw-*",
                "arn:aws:s3:::${local.project_prefix}-integration-*",
                "arn:aws:s3:::${local.project_prefix}-product-*",
                "arn:aws:s3:::${local.project_prefix}-powerbi"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:PutRolePolicy"
                ],
            "Resource": [
                "arn:aws:iam::${local.aws_account_id}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
