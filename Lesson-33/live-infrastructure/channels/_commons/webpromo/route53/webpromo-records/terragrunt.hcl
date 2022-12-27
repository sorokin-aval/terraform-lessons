dependency "zone"         { config_path = find_in_parent_folders("webpromo-zone") }
dependency "internal-alb" { config_path = find_in_parent_folders("lb/raifsite-internal-alb") }

terraform { source = local.account_vars.sources_route53_record }

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.account_vars.webpromo_domain)
  records = jsonencode([
    {
      name  = "web"
      type  = "A"
      alias = {
        name                   = dependency.internal-alb.outputs.lb_dns_name
        zone_id                = dependency.internal-alb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "admin"
      type  = "A"
      alias = {
        name                   = dependency.internal-alb.outputs.lb_dns_name
        zone_id                = dependency.internal-alb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name    = "lipton-db"
      type    = "CNAME"
      ttl     = 3600
      records = local.account_vars.dns_record_lipton_db
    },
    {
      name  = "public"
      type  = "A"
      alias = {
        name                   = dependency.internal-alb.outputs.lb_dns_name
        zone_id                = dependency.internal-alb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
  ])
}