include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v5.2.0"
}

dependency "cmdb_policy" {
  config_path = "../../policies/cmdb-jira-insight-policy/"
}
iam_role = local.account_vars.iam_role

locals {
  #account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name = basename(get_terragrunt_dir())
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))


  #current_tags = read_terragrunt_config("tags.hcl")
  #local_tags_map = local.current_tags.locals

  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals

  tags_map = merge(local.common_tags_map)

}

inputs = {

  trusted_role_arns = [
    "arn:aws:iam::291500210596:user/jira_insight_bot_CCOE-8464",
  ]

  create_role = true

  role_name         = local.name
  role_requires_mfa = false

  custom_role_policy_arns = [
    dependency.cmdb_policy.outputs.arn
  ]
  number_of_custom_role_policy_arns = 1

  tags = local.tags_map

}

