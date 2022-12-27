include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "${local.source_map.source_base_url}//modules/iam-assumable-role-with-oidc?ref=${local.source_map.ref}"
}

iam_role = local.account_vars.iam_role

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("app.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.common_tags.locals
  aws_account_id = local.account_vars.locals.aws_account_id
  module_tags = {
    Name             = "${basename(get_terragrunt_dir())}"
    application_role = "IAM Assumable Role"
  }
  role_name    = "${basename(get_terragrunt_dir())}"
  provider_url = local.app_vars.locals.provider_url
  audience     = local.app_vars.locals.audience
}

dependency "cloudwatch_exporter_iam_policy" {
  config_path = "../../iam-policy/CloudWatchExporterPolicyForEKSServiceAccount"
  mock_outputs = {
    arn = "arn:aws:iam::aws:policy/DummyPolicy"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

inputs = {
  create_role      = true
  role_name        = local.role_name
  role_description = "This role provides access to CloudWatch metrics on any our AWS account for Cloudwatch exporter's EKS Service"
  tags             = merge(local.module_tags, local.tags_map)
  aws_account_id   = local.aws_account_id
  provider_url     = local.provider_url
  oidc_fully_qualified_audiences = [
    local.audience
  ]
  role_policy_arns = [
    dependency.cloudwatch_exporter_iam_policy.outputs.arn
  ]
}
