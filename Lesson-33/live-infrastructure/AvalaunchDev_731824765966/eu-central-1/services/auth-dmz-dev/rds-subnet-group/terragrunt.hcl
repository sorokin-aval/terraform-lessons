include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
  name         = "${local.common_tags.locals.Name}-${local.common_tags.locals.Environment}"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//modules/db_subnet_group?ref=v4.2.0"
}

inputs = {
  name        = local.name
  description = "Subnet group for ${local.name} RDS"
  subnet_ids  = dependency.vpc.outputs.db_subnets.ids
  tags        = local.tags_map
}