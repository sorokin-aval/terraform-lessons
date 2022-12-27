include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}
dependency "lakeformation" {
  config_path  = "../../../../core-infrastructure/lakeformation-account/"
  mock_outputs = {
    kms_key = "arn:aws:kms::${local.aws_account_id}:key/44cb0f7e-7d73-43fb-aef0-dad32929ac3e"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Hardcode values
  layer       = "integration"
  bucket_name = "${local.project_vars.locals.resource_prefix}-${local.layer}-${local.tags_map.Project}"

  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  source_map = local.source_vars.locals
  tags_map   = local.project_vars.locals.project_tags

  aws_account_id = include.account.locals.aws_account_id
  region         = local.region_vars.locals.aws_region

}


inputs = {
  name        = "${local.project_vars.locals.project_prefix}-policy"
  path        = "/"
  description = "${local.project_vars.locals.project_prefix}-policy policy. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Sid": "AllowAccessToKMS",
            "Effect": "Allow",
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
            "Resource": [
                "${dependency.lakeformation.outputs.kms_key}"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "kms:DescribeCustomKeyStores",
                "kms:ListKeys",
                "kms:ListAliases"
            ],
            "Resource": "*"
        },
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
            "Effect": "Allow",
            "Action": [
                "athena:*"
            ],
            "Resource": [
                "arn:aws:athena:${local.region}:${local.aws_account_id}:workgroup/${local.project_vars.locals.project_prefix}"
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
                "tag:GetResources",
                "glue:GetSecurityConfiguration",
                "glue:GetSecurityConfigurations"
            ],
            "Resource": [
                "*"
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
                "arn:aws:glue:${local.region}:${local.aws_account_id}:database/*",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:table/*/*"
            ]
        },
        {
            "Action": [
                "glue:CreateTable",
                "glue:DeleteTable",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:BatchCreatePartition",
                "glue:CreatePartition"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:glue:${local.region}:${local.aws_account_id}:catalog",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:database/${local.project_vars.locals.project_prefix}",
                "arn:aws:glue:${local.region}:${local.aws_account_id}:table/${local.project_vars.locals.project_prefix}/*"
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
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:*Object"
            ],
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}/*"
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
        },
        {
            "Effect": "Allow",
            "Action": [
                "lakeformation:GetDataAccess",
                "lakeformation:GetResourceLFTags",
                "lakeformation:ListLFTags",
                "lakeformation:GetLFTag",
                "lakeformation:SearchTablesByLFTags",
                "lakeformation:SearchDatabasesByLFTags",
                "lakeformation:GetWorkUnits",
                "lakeformation:StartQueryPlanning",
                "lakeformation:GetWorkUnitResults",
                "lakeformation:GetQueryState",
                "lakeformation:GetQueryStatistics"
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
