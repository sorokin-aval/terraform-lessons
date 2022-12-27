include {
  path = find_in_parent_folders()
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"

locals {
  init           = run_cmd(find_in_parent_folders("templates/baseline/attach_policy.sh"), "${local.aws_account_id}")
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars    = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-baseline?ref=baseline_v2.3.1"

  extra_arguments "no_lock_for_plan" {
    commands = [
      "plan"
    ]
    arguments = [
      "-lock=false"
    ]
  }
}

inputs = {
  tags                  = merge(local.common_tags.locals)
  aws_win_patch_enabled = true
}
