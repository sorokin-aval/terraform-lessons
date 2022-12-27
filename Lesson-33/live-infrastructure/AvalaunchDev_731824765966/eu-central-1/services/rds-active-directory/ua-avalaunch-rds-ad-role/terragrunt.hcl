include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=v5.8.0"
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

dependency "ua-avalaunch-rds-ad-policy" {
  config_path = "../ua-avalaunch-rds-ad-policy/"

  # Used for successful first plan run
  mock_outputs = {
    arn = "arn:aws:iam:temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  role_name = basename(get_terragrunt_dir())

  tags_map = local.common_tags.locals.common_tags
}

inputs = {
  create_role           = true
  role_name             = local.role_name
  role_description      = "This role is used by RDS to work with AWS Directory"
  trusted_role_services = ["directoryservice.rds.amazonaws.com", "rds.amazonaws.com"]

  custom_role_policy_arns = [dependency.ua-avalaunch-rds-ad-policy.outputs.arn]
  tags                    = local.tags_map
}
