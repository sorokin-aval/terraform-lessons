include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group//?ref=v4.16.2"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.project_vars.locals.project_prefix}-postgres-sg"
}

inputs = {
  name                     = local.name
  description              = "Security group for ${local.name}"
  tags                     = local.tags_map
  #TODO: deploy vpc-info for dependency
  vpc_id                   = "vpc-0db2a458b42ad4e03"
  ingress_with_cidr_blocks = [
    {
      name        = "prod-eks-pool"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "prod eks pool"
      cidr_blocks = "100.124.64.0/20"
    },
    {
      name        = "common-eks-pool"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "terraform runner"
      cidr_blocks = "10.225.102.0/23"
    }
  ]


}
