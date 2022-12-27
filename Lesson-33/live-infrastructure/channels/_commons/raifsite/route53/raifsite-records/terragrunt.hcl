dependency "zone"         { config_path = find_in_parent_folders("raifsite-zone") }
dependency "internal-alb" { config_path = find_in_parent_folders("lb/raifsite-internal-alb") }
dependency "efs" { config_path = find_in_parent_folders("efs/cmsfront") }

terraform { source = local.account_vars.sources_route53_record }

iam_role = local.account_vars.iam_role

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.account_vars.domain)
  records = jsonencode([
    {
      name  = "alb"
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
      name    = "cms-db"
      type    = "CNAME"
      ttl     = 3600
      records = local.account_vars.dns_record_cms_db
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
    {
      name  = "promo"
      type  = "A"
      alias = {
        name                   = dependency.internal-alb.outputs.lb_dns_name
        zone_id                = dependency.internal-alb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "efs"
      type  = "CNAME"
      ttl     = 3600
      records = ["${dependency.efs.outputs.dns_name}"]
    },
  ])
}
