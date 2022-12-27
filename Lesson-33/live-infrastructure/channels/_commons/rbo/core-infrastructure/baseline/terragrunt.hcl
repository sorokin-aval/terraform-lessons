dependency "ami_tags_management" {
  config_path = find_in_parent_folders("rbo/iam/policy/ami-tags-management")
}

dependency "ami_create" {
  config_path = find_in_parent_folders("rbo/iam/policy/ami-create")
}

dependency "s3_policy_exchange" {
  config_path = find_in_parent_folders("rbo/iam/policy/s3-exchange")
}

dependency "ssm_policy" {
  config_path = find_in_parent_folders("rbo/iam/policy/ssm")
}

dependency "secret_manager_policy_app_read_write" {
  config_path = find_in_parent_folders("rbo/iam/policy/secret-manager-app-read-write")
}

terraform {
  source = local.account_vars.sources_baseline
}

locals {
  init         = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.account_vars.aws_account_id}")
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = "arn:aws:iam::${local.account_vars.aws_account_id}:role/BootstrapRole"

inputs = {
  ssm_run_as_enabled       = true
  ssm_run_as_default_user  = "ssm-user"
  ssm_idle_session_timeout = 60
  l2support_iam_tags       = { SSMSessionRunAs = local.account_vars.l2support_ssm_user }
  l2support_managed_policies_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "${dependency.s3_policy_exchange.outputs.arn}",
    "${dependency.ami_tags_management.outputs.arn}",
    "${dependency.ami_create.outputs.arn}",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole",
    "${dependency.secret_manager_policy_app_read_write.outputs.arn}"
  ]
  developer_iam_tags = { SSMSessionRunAs = local.account_vars.developer_ssm_user }
  developer = {
    managed_policies_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
      "${dependency.ssm_policy.outputs.arn}"
    ]
    trusted_role_arns = []
    enabled = true
    policy = []
  }
  platformops_iam_tags = { SSMSessionRunAs = "ssm-user" }
  tags             = local.tags_map,
  baseline-version = local.account_vars.baseline_ref
}
