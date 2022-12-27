include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//msk?ref=msk_v0.7.1"
  //  source = "../../../../../ua-avalaunch-terraform-modules//msk"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${get_terragrunt_dir()}/local.tfvars"
    ]
  }
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=100"]
  }
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
}

inputs = {
  tags                       = merge(local.common_tags.locals, { map-dba = "d-server-0177iq19e7pxm2" })
  environment                = local.account_vars.locals.environment
  certificate_authority_arns = local.global_vars.locals.certificate_authority_arns
}
