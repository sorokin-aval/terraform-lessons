dependency "zone"         { config_path = find_in_parent_folders("zone") }
dependency "internal-alb" { config_path = find_in_parent_folders("lb/internal-alb") }
dependency "internal-nlb" { config_path = find_in_parent_folders("lb/internal-nlb") }

terraform { source = local.account_vars.sources_route53_record }

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_id, local.account_vars.domain)
  records = jsonencode([
    {
      name  = "internal-alb"
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
      name  = "internal-nlb"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "auth-app"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "is-front-app"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name    = "opensearch"
      type    = "CNAME"
      ttl     = 3600
      records = local.account_vars.dns_records_opensearch
    },
    {
      name  = "logstash"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "leis-db"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "letran-db"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "leauth-db"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name  = "csk-db"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name    = "etl-db"
      type    = "CNAME"
      ttl     = 3600
      records = local.account_vars.dns_records_etl_db
    },
    {
      name    = "arch-db"
      type    = "CNAME"
      ttl     = 3600
      records = local.account_vars.dns_records_arch_db
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
      name  = "adm-app"
      type  = "A"
      alias = {
        name                   = dependency.internal-nlb.outputs.lb_dns_name
        zone_id                = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
  ])
}
