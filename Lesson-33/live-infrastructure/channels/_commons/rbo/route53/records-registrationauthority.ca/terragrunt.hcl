dependency "zone" { config_path = find_in_parent_folders("zone-${local.domain}") }

terraform { source = local.account_vars.sources_route53_record }

locals {
  domain       = "registrationauthority.ca"
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.domain)
  records = jsonencode([
    {
      name    = ""
      type    = "A"
      ttl     = 3600
      records = local.account_vars.dns_records_registrationauthority_ca
    },
  ])
}