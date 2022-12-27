dependency "db" {
  config_path = find_in_parent_folders("rds")
}

dependency "zone" {
  config_path = find_in_parent_folders("route53-zone")
}

terraform {
  source = local.account_vars.locals.sources["route53-records"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.account_vars.locals.tags
}

inputs = {
  zone_id = lookup(
    dependency.zone.outputs.route53_zone_zone_id,
    "${basename(dirname(find_in_parent_folders("route53-zone")))}.${local.account_vars.locals.domain}"
  )
  records_jsonencoded = jsonencode([
    {
      name    = "db"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.db.outputs.db_instance_address]
    },
  ])
}
