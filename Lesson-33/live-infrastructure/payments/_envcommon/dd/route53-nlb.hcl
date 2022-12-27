dependency "zone" {
  config_path = find_in_parent_folders("route53-zone")
}

dependency "nlb-internal" {
  config_path = find_in_parent_folders("nlb-internal/nlb")
}

terraform {
  source = local.account_vars.locals.sources["route53-records"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "${local.app_vars.locals.name}.${local.account_vars.locals.domain}")
  records = jsonencode([
    {
      name = "db"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
  ])
}
