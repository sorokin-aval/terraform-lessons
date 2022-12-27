include {
  path = find_in_parent_folders()
}
include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}
dependency "vpc" {
  # Hardcode!
  config_path = "../../imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.9.0"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "data.rbua"
}
inputs = {
  zones = {
    "data.rbua" = {
      comment = "Prod zone for data domain"
      vpc     = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        },
        {
          vpc_id = local.project_vars.locals.dns_vpc
        }
      ]
      tags = local.tags_map
    }
  }
}
