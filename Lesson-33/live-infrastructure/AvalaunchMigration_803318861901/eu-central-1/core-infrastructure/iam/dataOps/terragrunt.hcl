include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-saml?ref=v5.2.0"
}

locals {
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map      = local.common_tags.locals
  policies_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  role_name     = "DataOps"
}

inputs = {
  create_role          = true
  role_name            = local.role_name
  max_session_duration = 43200
  provider_id          = "arn:aws:iam::${get_aws_account_id()}:saml-provider/RBI-PingFederate"
  role_policy_arns     = local.policies_arns
  tags                 = local.tags_map
}
