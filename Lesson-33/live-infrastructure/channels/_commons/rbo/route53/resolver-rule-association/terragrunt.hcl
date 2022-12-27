dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

terraform { source = local.account_vars.sources_route53_rra }

locals { account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals }

iam_role = local.account_vars.iam_role

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id.id
  resolver_rule_associations = local.account_vars.route53_resolver_rule_associations
}
