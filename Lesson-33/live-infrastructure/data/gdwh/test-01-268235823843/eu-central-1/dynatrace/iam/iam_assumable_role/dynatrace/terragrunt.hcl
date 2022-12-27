include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "dynatrace" {
  config_path  = "../../iam_policy/dynatrace/"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}:policy/mock_policy_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
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
  role_name      = "${local.project_vars.locals.resource_prefix}-${basename(get_terragrunt_dir())}"
}

inputs = {
  create_role             = true
  create_instance_profile = true
  role_name               = local.role_name
  description             = "This role provides access to from NiFi EC2 to S3"
  tags                    = local.tags_map
  role_requires_mfa       = false
  role_sts_externalid     = ["8cb67e2c-54fa-4224-a385-7d1724c72811"]
  trusted_role_services   = [
  ]
  trusted_role_arns = [
    "arn:aws:iam::136812256255:role/Dynatrace-active-gateway",
    "arn:aws:iam::509560245411:root"
  ]
  custom_role_policy_arns = [
    dependency.dynatrace.outputs.arn
  ]
}
