terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-saml"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.account_vars.locals.tags
}

inputs = {
  create_role      = true
  role_name        = basename(get_terragrunt_dir())
  role_path        = "/"
  role_policy_arns = []
  provider_id      = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:saml-provider/RBI-PingFederate"
  tags             = local.account_vars.locals.tags
}
