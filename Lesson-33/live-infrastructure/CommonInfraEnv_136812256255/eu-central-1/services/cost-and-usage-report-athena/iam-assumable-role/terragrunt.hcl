include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-saml?ref=v4.18.0"
}

dependencies {
  paths = ["../iam-policy"]
}

dependency "iam-policy" {
  config_path = "../iam-policy"

  # Used for successful first plan run
  mock_outputs = {
    arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  tags_map = local.common_tags.locals
  # Extract out exact variables for reuse
  resource_prefix = "cost-and-usage-report-athena"
  aws_account_id  = local.account_vars.locals.aws_account_id
}

inputs = {
  create_role          = true
  role_name            = local.resource_prefix
  max_session_duration = 43200
  description          = "This role provides read access to costandusagereportdailyathena AWS Athena"
  tags                 = local.tags_map
  provider_id          = "arn:aws:iam::${local.aws_account_id}:saml-provider/RBI-PingFederate"
  role_policy_arns = [
    dependency.iam-policy.outputs.arn
  ]

}
