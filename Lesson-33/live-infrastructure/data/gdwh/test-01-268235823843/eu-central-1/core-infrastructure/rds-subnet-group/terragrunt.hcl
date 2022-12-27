include {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "vpc" {
  config_path = "../imported-vpc/"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${basename(get_terragrunt_dir())}"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//modules/db_subnet_group?ref=v4.2.0"
}


inputs = {
  name        = local.name
  description = "Subnet group for ${local.name} RDS"
  subnet_ids  = dependency.vpc.outputs.app_subnets.ids
  tags        = local.tags_map
}
