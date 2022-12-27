include {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}
dependency "vpc" {
  config_path = "../../core-infrastructure/imported-vpc/"
}

# vault address is manual since have no access to avalaunch vault right now with terraform
generate "provider_vault" {
  path      = "provider_vault.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "vault" {
    address = "https://vault.dev.avalaunch.aval"
    }
  EOF
}
locals {
  create_airflow              = true
  create_spark                = true
  create_airflow_elasticache  = true
  create_airflow_postgres_rds = true
  create_athena               = false
  create_eks_role             = false
  create_saml_role            = false
  create_kms                  = true
  create_vault_role           = false
  create_project_bucket       = false
  project_vars                = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars                = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                    = local.project_vars.locals.project_tags
  name                        = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}"
  layer                       = "integration"
  # project bucket is an Intermediate bucket between raw and product zones. Used to join data from multiple sources and make transformations
  project_bucket              = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}-${local.tags_map.Project}"
  kms_key                     = true
  role                        = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Project}"
  kms_description             = "KMS key for project ${local.tags_map.Project} usage"
  kms_policy                  = <<EOF
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
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
                "AWS": "arn:aws:iam::${local.aws_account_id}:role/DataOps"
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
  airflow_configuration       = {
    "url" : "https://${local.tags_map.Project}.apps.avalaunch.aval",
    "idp_client_id" : "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}"
    "idp_url" : "https://dex.common.avalaunch.aval"
    "generate_secret" : false
  }
  redis_database_name          = "${local.tags_map.Project}"
  redis_engine_version         = "6.2"
  redis_instance_type          = "cache.t4g.micro" # should be same for prod, but could be extended
  redis_cluster_size           = 1
  postgres_identifier          = "${local.tags_map.Project}"
  postgres_db_name             = "airflow"
  postgres_instance_class      = "db.t4g.small"
  postgres_deletion_protection = false
  aws_account_id               = local.account_vars.locals.aws_account_id
  vault_path                   = "secret/service-internal-secrets/${local.tags_map.Environment}/${local.tags_map.Tech_domain}"
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-analytics-platform//?ref=data-analytics-platform_v1.0.3"
}


inputs = {
  bucket                           = local.project_bucket
  attach_require_latest_tls_policy = true
  versioning                       = {
    enabled = true
  }
  tags                            = local.tags_map
  kms_description                 = local.kms_description
  kms_policy                      = local.kms_policy
  airflow_config                  = local.airflow_configuration
  redis_database_name             = local.redis_database_name
  redis_engine_version            = local.redis_engine_version
  redis_instance_type             = local.redis_instance_type
  redis_cluster_size              = local.redis_cluster_size
  postgres_identifier             = local.postgres_identifier
  postgres_db_name                = local.postgres_db_name
  postgres_instance_class         = local.postgres_instance_class
  postgres_deletion_protection    = local.postgres_deletion_protection
  postgres_create_db_subnet_group = true
  postgres_db_subnet_group_name   = "eks"
  create_airflow                  = local.create_airflow
  create_spark                    = local.create_spark
  create_airflow_elasticache      = local.create_airflow_elasticache
  create_airflow_postgres_rds     = local.create_airflow_postgres_rds
  create_athena                   = local.create_athena
  create_eks_role                 = local.create_eks_role
  create_saml_role                = local.create_saml_role
  create_kms                      = local.create_kms
  create_vault_role               = local.create_vault_role
  create_bucket                   = local.create_project_bucket
  vault_path                      = local.vault_path
}
