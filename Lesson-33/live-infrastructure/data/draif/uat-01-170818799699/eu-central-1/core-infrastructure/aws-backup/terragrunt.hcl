include "root" {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-backup/ec2?ref=v2.1.1"
}

inputs = {
  tags = local.tags_map
}
