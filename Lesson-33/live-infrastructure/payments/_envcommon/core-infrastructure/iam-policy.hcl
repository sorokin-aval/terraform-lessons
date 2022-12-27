terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name   = basename(get_terragrunt_dir())
  path   = "/"
  policy = ""
  tags   = merge(local.account_vars.locals.tags, { "Name" = basename(get_terragrunt_dir()) })
}
