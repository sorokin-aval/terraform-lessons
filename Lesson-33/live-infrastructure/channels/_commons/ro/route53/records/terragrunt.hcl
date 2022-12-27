dependency "zone" {
  config_path = find_in_parent_folders("zone")
}

dependency "console-alb" {
  config_path = find_in_parent_folders("lb/console-alb")
}

dependency "internal-nlb" {
  config_path = find_in_parent_folders("lb/internal-nlb")
}

terraform {
  source = local.account_vars.sources_route53_record
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.account_vars.domain)
  records = jsonencode([
    {
      name = local.account_vars.dns_name_console
      type = "A"
      alias = {
        name    = dependency.console-alb.outputs.lb_dns_name
        zone_id = dependency.console-alb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "internal-nlb"
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = local.account_vars.dns_name_logstash
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "opensearch"
      type = "CNAME"
      ttl  = 3600
      records = local.account_vars.dns_records_opensearch
    },
    {
      name = "mess-db"
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "auth-db"
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "dvo-db"
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "int-db"
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "piarch-db"
      type = "A"
      alias = {
        name    = dependency.internal-nlb.outputs.lb_dns_name
        zone_id = dependency.internal-nlb.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
  ])
}
