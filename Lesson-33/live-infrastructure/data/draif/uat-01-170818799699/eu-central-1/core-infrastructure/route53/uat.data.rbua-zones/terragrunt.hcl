include {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
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
  envcommon    = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "uat.data.rbua"
}

inputs = {
  zones = {
    "uat.data.rbua" = {
      comment = "Uat zone for data domain"
      vpc     = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        },
        {
          vpc_id = "vpc-0f00f1b872ab5dff9" # common
        },
        {
          vpc_id = "vpc-09a74db90a21bf6f1" # avalaunch dev
        }
      ]
      tags = local.tags_map
    }
  }
}
