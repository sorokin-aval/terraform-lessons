include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "eks" {
  config_path = find_in_parent_folders("eks")
}

dependency "iam-policy" {
  config_path = find_in_parent_folders("iam-policy")
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-eks-role?version=5.5.2"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  tags_map     = local.common_tags.locals.common_tags
}

inputs = {
  role_name        = "AmazonEKSDomainProvisionGithubRunnerRole"
  role_description = "IAM Role for domain-provisioning Github Runners serviceaccount"

  ### Uncomment when new module version released https://github.com/terraform-aws-modules/terraform-aws-iam/issues/289
  ### For now it's workaround by hands
  #allow_self_assume_role = true

  cluster_service_accounts = {
    (dependency.eks.outputs.cluster_id) = ["actions-runner-controller:domain-provisioning-gh-runner"]
  }

  role_policy_arns = {
    (dependency.iam-policy.outputs.name) = "${dependency.iam-policy.outputs.arn}"
  }

  tags = local.tags_map
}
