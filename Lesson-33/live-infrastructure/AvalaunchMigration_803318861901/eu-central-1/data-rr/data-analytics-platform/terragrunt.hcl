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

# vault address is manual since have no access to avalaunch vault right now with terraform
generate "provider_vault" {
  path      = "provider_vault.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "vault" {
    address = "https://vault.prod.avalaunch.aval"
    auth_login {
      path = "auth/kubernetes-common/login"

      parameters = {
        role = "atlantis"
        jwt  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
        }
      }
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
  create_kms                  = false
  create_vault_role           = false
  create_project_bucket       = false
  project_vars                = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars                = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                    = local.project_vars.locals.project_tags
  name                        = local.project_vars.locals.project_prefix
  layer                       = "integration"
  # project bucket is an Intermediate bucket between raw and product zones. Used to join data from multiple sources and make transformations
  project_bucket              = "${local.project_vars.locals.resource_prefix}-${local.layer}-${local.tags_map.Project}"
  kms_key                     = true
  airflow_configuration       = {
    "url" : "https://${local.tags_map.Project}.apps.avalaunch.aval",
    "idp_client_id" : "${local.tags_map.entity}-${local.tags_map.domain}-${local.tags_map.Project}"
    "idp_url" : "https://dex.common.avalaunch.aval"
    "generate_secret" : false
  }
  redis_engine_version         = "6.2"
  redis_instance_type          = "cache.t4g.micro" # should be same for prod, but could be extended
  redis_cluster_size           = 1
  postgres_db_name             = "airflow"
  postgres_instance_class      = "db.t4g.small"
  postgres_deletion_protection = false
  aws_account_id               = local.account_vars.locals.aws_account_id
  vault_path                   = "secret/service-internal-secrets/${local.tags_map["security:environment"]}/${local.tags_map.Project}"
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-analytics-platform//?ref=v3.0.0"
}


inputs = {
  tags                            = local.tags_map
  project                         = local.tags_map.Project
  airflow_config                  = local.airflow_configuration
  redis_engine_version            = local.redis_engine_version
  redis_instance_type             = local.redis_instance_type
  redis_cluster_size              = local.redis_cluster_size
  postgres_identifier             = "${local.tags_map.Project}-airflow-postgres"
  postgres_db_name                = local.postgres_db_name
  postgres_kms_key_id             = local.project_vars.locals.kms_key
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
  k8s_namespace                   = lower("${local.tags_map.Project}-${local.tags_map["security:environment"]}")
}
