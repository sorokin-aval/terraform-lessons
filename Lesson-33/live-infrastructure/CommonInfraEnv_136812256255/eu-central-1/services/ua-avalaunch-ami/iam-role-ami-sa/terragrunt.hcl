include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-role-for-service-accounts-eks?ref=v5.2.0"
  # make sure CI platform is added to hashes
  extra_arguments "add_signatures_for_other_platforms" {
    commands = contains(get_terraform_cli_args(), "lock") ? ["providers"] : []
    # use env_vars since "provider locks" argument order fails
    env_vars = {
      TF_CLI_ARGS_providers_lock = "-platform=darwin_amd64 -platform=linux_amd64"
      TF_PLUGIN_CACHE_DIR        = "" # disable cache for auto init
    }
  }
}

dependency "eks" {
  config_path = "../../../eks"
  mock_outputs = {
    oidc_provider_arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

dependency "iam-policy-ami-sa" {
  config_path = "../iam-policy-ami-sa"

  # Used for successful first plan run
  mock_outputs = {
    arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map    = local.common_tags.locals.common_tags

  role_name        = "ua-avalaunch-ami"
  k8s_sa_namespace = "actions-runner-controller"
  k8s_sa_name      = "ua-avalaunch-ami"
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  role_name        = local.role_name
  role_description = "This role is used by service account attached to GH runner for ua-avalaunch-ami repository"
  oidc_providers = {
    terraform = {
      provider_arn = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "${local.k8s_sa_namespace}:${local.k8s_sa_name}"
      ]
    }
  }

  role_policy_arns = {
    sts = dependency.iam-policy-ami-sa.outputs.arn
  }
  tags = local.tags_map
}
