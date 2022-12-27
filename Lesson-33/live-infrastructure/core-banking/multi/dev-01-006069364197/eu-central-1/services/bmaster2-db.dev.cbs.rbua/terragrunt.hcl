include {
  path = find_in_parent_folders()
}

terraform {
  module "rds_example_complete-oracle" {
    source  = "terraform-aws-modules/rds/aws//examples/complete-oracle"
    version = "5.1.0"
  }
}

dependency "vpc" {
  config_path = "../../core-infrastructure/baseline/"
}

dependency "sg_ORACLE_DB" {
  config_path = "../../sg/ORACLE_DB"
}
dependency "sg_commvault" {
  config_path = "../../sg/CommVault"
}

dependency "sg_ZabbixAgent" {
  config_path = "../../sg/ZabbixAgent"
}

locals {
  name = basename(get_terragrunt_dir())
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  current_tags = read_terragrunt_config("tags.hcl")
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals
  local_tags_map = local.current_tags.locals
  tags_map = merge(local.common_tags_map, local.local_tags_map)

}

inputs = {
  identifier = "bmaster-2"

  engine               = "oracle-ee"
  engine_version       = "19.0.0.0.ru-2022-07.rur-2022-07.r1"
  family               = "oracle-ee-19-s3" # DB parameter group
  major_engine_version = "12.1"            # DB option group
  instance_class       = "db.t3.small"
  license_model        = "bring-your-own-license"

  allocated_storage     = 20
  max_allocated_storage = 300
  storage_encrypted     = false

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  name                   = "BMSTR"
  username               = "admin"
  create_random_password = true
  random_password_length = 12
  port                   = 1521

  multi_az               = false
  subnets_names          = ["LZ-Aval_SRE_Test_01-InternalA", "LZ-Aval_SRE_Test_01-InternalB"]

  enabled_cloudwatch_logs_exports = ["alert", "audit"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = "my-rds-monitoring-role"

  character_set_name = "CL8MSWIN1251"

  tags = local.tags_map
  volume_tags = local.tags_map

}
#####
/*
inputs = {
    name  = local.name
    ami           = "ami-0f8721cf0671247ba" 
    instance_type = "t2.micro" 
    subnet_id     = dependency.vpc.outputs.db_subnets.ids[2]
    key_name = dependency.vpc.outputs.ssh_key_ids[0]
    tags = local.tags_map
    volume_tags = local.tags_map

    iam_instance_profile = "test-oracle-s3-readonly"
    create_iam_role_ssm = false
    create_security_group_inline = false
 
    vpc_security_group_ids = [
        dependency.sg_ORACLE_DB.outputs.security_group_id,
        dependency.sg_commvault.outputs.security_group_id,
        dependency.sg_ZabbixAgent.outputs.security_group_id
        ]
}
*/