include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "zone" {
  # Hardcode!
  config_path = "../dev.cbs.rbua-zones/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
}


inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "dev.cbs.rbua")
  records = jsonencode([
    {
      name    = "xml-app.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.227.44.46"]
    },
    {
      name    = "pre.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.227.44.223"]
    }


    ]
  )
}

