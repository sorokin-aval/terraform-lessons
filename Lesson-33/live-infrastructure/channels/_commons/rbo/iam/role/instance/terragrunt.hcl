dependency "s3_policy_exchange" {
  config_path = find_in_parent_folders("policy/s3-exchange")
}

dependency "s3_policy_app_logs" {
  config_path = find_in_parent_folders("policy/s3-app-logs")
}

dependency "secret_manager_policy_app_read_only" {
  config_path = find_in_parent_folders("policy/secret-manager-app-read-only")
}

terraform {
  source = local.account_vars.sources_iam_assumable_role
}

locals {
  name         = "Instance"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  role_name               = local.name
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services   = [ "ec2.amazonaws.com" ]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation",
    "${dependency.s3_policy_exchange.outputs.arn}",
    "${dependency.s3_policy_app_logs.outputs.arn}",
    "${dependency.secret_manager_policy_app_read_only.outputs.arn}",
    "${local.account_vars.ccoe_ssm_iam_policy}"
  ]
  number_of_custom_role_policy_arns = 6

  tags = merge(local.tags_map, { Name = local.name })
}
