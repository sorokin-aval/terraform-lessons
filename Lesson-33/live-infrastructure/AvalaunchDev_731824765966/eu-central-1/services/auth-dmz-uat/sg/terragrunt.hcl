include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

# Hardcode!
dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
  name         = "${local.common_tags.locals.Name}-${local.common_tags.locals.Environment}"
}

inputs = {
  name        = local.name
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_cidr_blocks = ["${dependency.vpc.outputs.vpc_id.cidr_block}"]
  ingress_with_cidr_blocks = [
    {
      name        = "postgre"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "postgre"
      cidr_blocks = "${dependency.vpc.outputs.vpc_id.cidr_block}"
    }
  ]
  egress_with_cidr_blocks = [
    {
      name        = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}