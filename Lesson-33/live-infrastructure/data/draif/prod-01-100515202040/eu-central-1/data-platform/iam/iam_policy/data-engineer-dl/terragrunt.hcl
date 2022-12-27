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
  # Hardcode values
  bucket_name = "${local.project_prefix}-athena-data-lake-results"

  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))  
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out exact variables for reuse
#   resource_prefix = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}"

  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  project_prefix  = local.project_vars.locals.project_prefix
  region         = local.region_vars.locals.aws_region

}


inputs = {
  name        = "${local.project_prefix}-data-engineer-dl-policy"
  path        = "/"
  description = "${local.project_prefix}-data-engineer-policy policy. Created with Terragrunt"
  policy      = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "athena:GetDatabase",
            "athena:GetTableMetadata",
            "athena:ListDatabases",
            "athena:ListDataCatalogs",
            "athena:ListEngineVersions",
            "athena:ListTableMetadata",
            "athena:ListWorkGroups"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "athena:*"
         ],
         "Resource":[
            "arn:aws:athena:${local.region}:${local.aws_account_id}:workgroup/*",
            "arn:aws:athena:${local.region}:${local.aws_account_id}:workgroup/${local.project_prefix}-data-engineer"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "glue:GetDataCatalogEncryptionSettings",
            "glue:GetCatalogImportStatus"
         ],
         "Resource":[
            "arn:aws:glue:eu-central-1:${local.aws_account_id}:catalog"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "glue:DeleteCrawler",
            "glue:GetCrawler",
            "glue:GetTags",
            "glue:StartCrawler",
            "glue:StartCrawlerSchedule",
            "glue:StopCrawler",
            "glue:StopCrawlerSchedule",
            "glue:UpdateCrawler",
            "glue:UpdateCrawlerSchedule"
         ],
         "Resource":[
            "arn:aws:glue:${local.region}:${local.aws_account_id}:crawler/${local.project_prefix}-*"
         ]
      },
      {
            "Action": [
                "kms:GetPublicKey",
                "kms:Decrypt",
                "kms:ListKeyPolicies",
                "kms:UntagResource",
                "kms:ListRetirableGrants",
                "kms:GetKeyPolicy",
                "kms:Verify",
                "kms:ListResourceTags",
                "kms:ReEncryptFrom",
                "kms:ListGrants",
                "kms:VerifyMac",
                "kms:GetParametersForImport",
                "kms:TagResource",
                "kms:Encrypt",
                "kms:GetKeyRotationStatus",
                "kms:ReEncryptTo",
                "kms:DescribeKey"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:kms:eu-central-1:100515202040:key/44cb0f7e-7d73-43fb-aef0-dad32929ac3e"
            ],
            "Sid": "AllowAccessToKMS"
        },
      {
         "Effect":"Allow",
         "Action":[
            "glue:BatchGetCrawlers",
            "glue:CreateCrawler",
            "glue:GetClassifier",
            "glue:GetClassifiers",
            "glue:GetCrawlers",
            "glue:GetCrawlerMetrics",
            "glue:GetSecurityConfiguration",
            "glue:GetSecurityConfigurations",
            "glue:ListCrawlers",
            "tag:GetResources"
         ],
         "Resource":[
            "*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "glue:UpdateDatabase",
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:CreateDatabase",
            "glue:DeleteDatabase"
         ],
         "Resource":[
            "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog",
            "arn:aws:glue:${local.region}:${local.aws_account_id}:database/*"
         ]
      },
      {
         "Sid":"WouldBeRemoved2",
         "Effect":"Allow",
         "Action":[
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
         "Resource":[
            "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog",
            "arn:aws:glue:${local.region}:${local.aws_account_id}:database/*",
            "arn:aws:glue:${local.region}:${local.aws_account_id}:table/*/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "lakeformation:GetDataAccess",
            "lakeformation:GetLFTag",
            "lakeformation:GetQueryState",
            "lakeformation:GetQueryStatistics",
            "lakeformation:GetResourceLFTags",
            "lakeformation:GetWorkUnits",
            "lakeformation:GetWorkUnitResults",
            "lakeformation:ListLFTags",
            "lakeformation:StartQueryPlanning",
            "lakeformation:SearchDatabasesByLFTags",
            "lakeformation:SearchTablesByLFTags"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "lakeformation:CancelTransaction",
            "lakeformation:CommitTransaction",
            "lakeformation:DeleteObjectsOnCancel",
            "lakeformation:DescribeTransaction",
            "lakeformation:ExtendTransaction",
            "lakeformation:GetTableObjects",
            "lakeformation:ListTransactions",
            "lakeformation:StartTransaction",
            "lakeformation:UpdateTableObjects"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "lakeformation:AddLFTagsToResource",
            "lakeformation:BatchGrantPermissions",
            "lakeformation:BatchRevokePermissions",
            "lakeformation:GrantPermissions",
            "lakeformation:ListPermissions",
            "lakeformation:RemoveLFTagsFromResource",
            "lakeformation:RevokePermissions"
         ],
         "Resource":"*"
      },
      {
         "Action":[
            "iam:PassRole"
         ],
         "Effect":"Allow",
         "Resource":[
            "arn:aws:iam::${local.aws_account_id}:role/AWSGlueServiceRole*",
            "arn:aws:iam::${local.aws_account_id}:role/${local.project_prefix}-glue-crawler",
            "arn:aws:iam::${local.aws_account_id}:role/${local.project_prefix}-lakeformation" 
         ],
         "Condition":{
            "StringLike":{
               "iam:PassedToService":[
                  "glue.amazonaws.com"
               ]
            }
         }
      },
      {
         "Action":[
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "logs:StartQuery",
            "logs:StopQuery",
            "logs:TestMetricFilter",
            "logs:FilterLogEvents"
         ],
         "Effect":"Allow",
         "Resource":"arn:aws:logs:${local.region}:${local.aws_account_id}:log-group:aws-glue/crawlers:*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "iam:ListRoles",
            "iam:ListUsers",
            "logs:DescribeLogStreams",
            "cloudwatch:GetMetricData",
            "cloudwatch:ListDashboards",
            "s3:ListAllMyBuckets"
         ],
         "Resource":[
            "*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetObject"
         ],
         "Resource":[
            "arn:aws:s3:::rbua-data-nifi-*/*",
            "arn:aws:s3:::${local.project_prefix}-raw-*/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:List*",
            "s3:*Object"
         ],
         "Resource":[
            "arn:aws:s3:::${local.bucket_name}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
         ],
         "Resource":[
            "arn:aws:s3:::rbua-data-nifi-*",
            "arn:aws:s3:::${local.project_prefix}-raw-*",
            "arn:aws:s3:::${local.bucket_name}/*"
         ]
      }
   ]
}

EOF

  tags = local.tags_map

}
