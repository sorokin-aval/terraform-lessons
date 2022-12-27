include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "crawler-policy" {
  config_path = "../../iam_policy/glue-crawler/"

  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
  mock_outputs                            = {
    arn = "arn:aws:iam::${local.aws_account_id}:role/test"
  }
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  module_tags    = {
    Role = local.role_name,
    Name = local.role_name
  }
  role_name = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${basename(get_terragrunt_dir())}"
}

inputs = {
  create_role           = true
  role_name             = local.role_name
  description           = "This role used to crawl data from S3 to Glue. To grant permissions use LF"
  tags                  = merge(local.module_tags, local.tags_map)
  role_requires_mfa     = false
  trusted_role_services = [
    "glue.amazonaws.com"
  ]
  custom_role_policy_arns = [
    dependency.crawler-policy.outputs.arn,
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]
}
