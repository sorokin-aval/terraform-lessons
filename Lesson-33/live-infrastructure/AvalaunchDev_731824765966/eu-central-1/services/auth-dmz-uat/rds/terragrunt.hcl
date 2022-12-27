include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role
dependency "sg" {
  config_path = "../sg"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

dependency "subnet_group" {
  config_path = "../rds-subnet-group"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
  name         = "${local.common_tags.locals.Name}-${local.common_tags.locals.Environment}"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=v4.2.0"
}

inputs = {
  identifier             = local.name
  engine                 = "postgres"
  engine_version         = "14.1"
  family                 = "postgres14"
  major_engine_version   = "14"
  instance_class         = "db.t4g.medium"
  db_name                = "keycloak"
  username               = "keycloak"
  port                   = 5432
  multi_az               = false
  allocated_storage      = 20
  db_subnet_group_name   = dependency.subnet_group.outputs.db_subnet_group_id
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]

  maintenance_window = "Sun:01:00-Sun:02:00"
  backup_window      = "03:00-06:00"
  tags               = local.tags_map

}