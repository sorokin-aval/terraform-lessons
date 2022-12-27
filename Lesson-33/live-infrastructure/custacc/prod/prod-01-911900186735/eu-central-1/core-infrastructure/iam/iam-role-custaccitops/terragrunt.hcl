#custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-saml?ref=v5.2.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  role_name    = "CustaccItOps"
}

inputs = {
  create_role          = true
  role_name            = local.role_name
  max_session_duration = 3600
  provider_id          = "arn:aws:iam::${get_aws_account_id()}:saml-provider/RBI-PingFederate"
  role_policy_arns = [
    "arn:aws:iam::${local.account_vars.locals.aws_account_id}:policy/EC2_start_stop_tag",
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::${local.account_vars.locals.aws_account_id}:policy/rbua-baseline-mandatory-SSM-SessionPolicy"
  ]
  tags = local.app_vars.locals.tags
}
