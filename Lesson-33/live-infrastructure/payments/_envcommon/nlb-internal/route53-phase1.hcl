dependency "zone" {
  config_path = find_in_parent_folders("core-infrastructure/route53-zone")
}

dependency "nlb-internal" {
  config_path = find_in_parent_folders("nlb-internal/nlb")
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.account_vars.locals.tags
}

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.account_vars.locals.domain)
  records = jsonencode([
    {
      name = "nlb"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "db.norkom"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "db.pte"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "db.is-card"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "db.tm"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    },
    {
      name = "db.vpos"
      type = "A"
      alias = {
        name                   = dependency.nlb-internal.outputs.lb_dns_name
        zone_id                = dependency.nlb-internal.outputs.lb_zone_id
        evaluate_target_health = true
      }
    }
  ])
}
