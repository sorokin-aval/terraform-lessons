terraform {
  source = local.account_vars.locals.sources["key-pair"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
}

# Required public_key in inputs
inputs = {
  key_name     = basename(get_terragrunt_dir())
  tags         = merge(local.tags_map.locals.tags, { Name = basename(get_terragrunt_dir()) })
}