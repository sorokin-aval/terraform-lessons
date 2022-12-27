include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

dependency "zone" {
  # Hardcode!
  config_path = "../uat.rbua-zones/"
}

dependency "alb" {
  # Hardcode!
  config_path = "../../alb-entrypoint-internal/alb/"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
}

inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "uat.rinfo.rbua")
  records = jsonencode([
    {
      name           = "ap01"
      type           = "A"
      ttl            = 3600
      records        = ["10.225.106.83"]
    }
  ])
}