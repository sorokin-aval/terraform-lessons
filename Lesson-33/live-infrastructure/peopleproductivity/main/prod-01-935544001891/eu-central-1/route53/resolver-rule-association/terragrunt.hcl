include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" { 
  config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

terraform { 
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/resolver-rule-associations?ref=v2.8.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
 
inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id.id
  resolver_rule_associations = {
    "aval"     = { resolver_rule_id = "rslvr-rr-7386ce4b2e2c46b6a" },
    "rbua"     = { resolver_rule_id = "rslvr-rr-cd8ee6dcf31040d5b" },
  }
}
