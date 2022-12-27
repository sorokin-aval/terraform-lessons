include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map   = merge(local.project_vars.locals.project_tags, { Name = "legacy" })
  name       = "${local.tags_map.Name}-${local.tags_map.Environment}-${local.tags_map.Project}-${basename(get_terragrunt_dir())}"
}

inputs = {
  name        = local.name
  description = "Security group for ${local.name}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      description = "HTTP access to SOTA ALB"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      rule        = "https-443-tcp"
      description = "HTTPS access to SOTA ALB"
      cidr_blocks = "10.0.0.0/8"
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
