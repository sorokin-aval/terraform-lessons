terraform {
  source = local.account_vars.locals.sources.acm
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  pca_arn = local.account_vars.locals.pca

  certificates = {
    "${local.app_vars.locals.name}" = {
      domain_name = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
    }
  }

}