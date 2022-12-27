dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb" { config_path = find_in_parent_folders("alb-internal/alb") }
dependency "zone" { config_path = find_in_parent_folders("route53-zone") }

terraform {
  source = local.account_vars.locals.sources["route53-alb"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  alb_arn             = dependency.alb.outputs.lb_arn,
  alb_route53_records = ["slb"],
  hosted_zone         = lookup(dependency.zone.outputs.route53_zone_zone_id, "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"),
}
