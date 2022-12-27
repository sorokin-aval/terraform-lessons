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
  config_path = find_in_parent_folders("CommonInfraEnv_136812256255/eu-central-1/eks")
  mock_outputs = {
    oidc_provider_arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

dependency "iam-policy-packer-sa" {
  config_path = find_in_parent_folders("prod-01-136812256255/eu-central-1/services/packer/iam-policy-packer-sa")

  # Used for successful first plan run
  mock_outputs = {
    arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map    = local.common_tags.locals

  role_name               = "packer"
  terraform_k8s_namespace = "actions-runner-controller"
  terraform_k8s_name      = "ua-platformsops-golden-image"
  account_vars            = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id          = local.account_vars.locals.aws_account_id
}

inputs = {
  role_name        = local.role_name
  role_description = "This role is used by service account attached to GH runner for ua-avalaunch-terragrunt repository"
  oidc_providers = {
    terraform = {
      provider_arn = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "${local.terraform_k8s_namespace}:${local.terraform_k8s_name}"
      ]
    }
  }

  role_policy_arns = {
    sts = dependency.iam-policy-packer-sa.outputs.arn
  }
  tags = local.tags_map
}
