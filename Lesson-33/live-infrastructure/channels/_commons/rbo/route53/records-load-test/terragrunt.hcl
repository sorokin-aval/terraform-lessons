dependency "zone"     { config_path = find_in_parent_folders("zone") }
dependency "instance" { config_path = find_in_parent_folders("ec2/instance/${local.name}") }

terraform { source = local.account_vars.sources_route53_record }

locals {
  name         = "load-test"
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_id, local.account_vars.domain)
  records = jsonencode([
    {
      name    = "${local.name}.ec2"
      type    = "A"
      ttl     = 3600
      records = [dependency.instance.outputs.wrapper["${local.name}"].private_ip]
    }
  ])
}
