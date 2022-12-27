dependency "aurora" {
  config_path = find_in_parent_folders("aurora")
}

dependency "zone" {
  config_path = find_in_parent_folders("route53-zone")
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.10.1"
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
      records = [dependency.aurora.outputs.cluster_endpoint]
    },
    {
      name    = "db-ro"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.aurora.outputs.cluster_reader_endpoint]
    },
  ])
}
