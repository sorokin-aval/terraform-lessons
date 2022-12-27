dependency "zone" {
  config_path = find_in_parent_folders("core-infrastructure/route53-zone")
}

dependency "nlb-nlb-transit-db-is-card" {
  config_path = find_in_parent_folders("nlb-transit-db-is-card/nlb")
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.account_vars.locals.domain)
  records = jsonencode([
    {
      name = "transit-db.is-card"
      type = "A"
      alias = {
        name                   = dependency.nlb-nlb-transit-db-is-card.outputs.lb_dns_name
        zone_id                = dependency.nlb-nlb-transit-db-is-card.outputs.lb_zone_id
        evaluate_target_health = true
      }
    }
  ])
}
