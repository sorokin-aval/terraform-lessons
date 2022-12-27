include {
  path = find_in_parent_folders()
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-saml?ref=v5.2.0"
}

iam_role = local.account_vars.iam_role

dependency "policy" {
	config_path = "../../../policies/MWAA/${basename(get_terragrunt_dir())}"
}

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  role_name     = basename(get_terragrunt_dir())

  current_tags = read_terragrunt_config("tags.hcl")
  local_tags_map = local.current_tags.locals

  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals

  tags_map = merge(local.common_tags_map, local.local_tags_map)
}

inputs = {
  create_role          = true
  role_name            = local.role_name
  max_session_duration = 43200
  provider_id          = "arn:aws:iam::${get_aws_account_id()}:saml-provider/RBI-PingFederate"
  role_policy_arns     = [dependency.policy.outputs.arn]
  tags                 = local.tags_map
}
