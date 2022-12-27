terraform {
  source = local.account_vars.locals.sources["route-rules"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

locals {
  account_vars                        = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

# Required public_key in inputs
inputs = {
  vpc_id                              = dependency.vpc.outputs.vpc_id.id
  resolver_rule_associations          = local.account_vars.locals.route53_resolver_rule_associations
}