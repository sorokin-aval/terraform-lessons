include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "eks" {
  config_path = find_in_parent_folders("eks")
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info") 
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-harbor.git?ref=v1.0.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  harbor_tags = {
    "ea:application-id"        = "20629"
    "ea:application-name"      = "Avalaunch"
    "ea:shared-service"        = "false"
    internet-faced             = "false"
    map-dba                    = ""
  }
}

inputs = {
  eks_id                 = dependency.eks.outputs.cluster_id
  vpc_id                 = dependency.vpc.outputs.vpc_id.id
  rds_subnet_ids         = dependency.vpc.outputs.app_subnets.ids
  eks_subnet_cidr_blocks = dependency.vpc.outputs.app_subnet_cidr_blocks

  rds_instance_class         = "db.t3.medium"
  rds_random_password_length = 16
  rds_allocated_storage      = 10
  rds_max_allocated_storage  = 0
  rds_engine                 = "postgres"
  rds_engine_version         = "13.7"
  rds_family                 = "postgres13"
  rds_identifier             = "harbor-db"
  rds_db_name                = "harbor"
  rds_username               = "harbor_admin"
  rds_skip_final_snapshot    = true

  harbor_namespace       = "harbor"
  harbor_service_account = "default"

  rds_parameters = [
    {
      name         = "max_connections"
      value        = "300"
      apply_method = "pending-reboot"
    }
  ]

  common_tags = local.common_tags.locals.common_tags
  rds_tags    = local.harbor_tags
}
