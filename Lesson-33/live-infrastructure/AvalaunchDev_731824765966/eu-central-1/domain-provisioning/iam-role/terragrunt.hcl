include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "iam-policy" {
  config_path = find_in_parent_folders("iam-policy")
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-assumable-role?version=5.5.2"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  tags_map     = local.common_tags.locals.common_tags
}

inputs = {
  role_name         = "AmazonEKSDomainProvisionGithubRunnerRole"
  role_description  = "IAM Role for domain-provisioning Github Runners which allows to assume from common EKS"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [
    dependency.iam-policy.outputs.arn
  ]

  trusted_role_arns = [
    "arn:aws:iam::136812256255:role/AmazonEKSDomainProvisionGithubRunnerRole",
  ]

  tags = local.tags_map
}
