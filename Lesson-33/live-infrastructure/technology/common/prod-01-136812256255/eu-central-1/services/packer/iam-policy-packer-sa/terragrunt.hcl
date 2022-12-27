include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

locals {
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map       = local.common_tags.locals
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id

  name = "packer-service-account-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sts:AssumeRole"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:iam::*:role/packer-role"
        ]
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceOrgID" : "o-81787ajq8u"
          }
        }
      },
      {
        "Action" : [
          "ssm:StartAutomationExecution"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  # https://github.com/hashicorp/terraform/issues/27769

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
inputs = {
  name        = local.name
  description = "IAM policy used by ansible role to assume packer-role roles"
  policy      = local.policy
}
