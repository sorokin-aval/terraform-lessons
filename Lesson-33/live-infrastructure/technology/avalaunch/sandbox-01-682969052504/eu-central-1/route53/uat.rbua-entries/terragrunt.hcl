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
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map    = local.common_tags.locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
}

inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "uat.rbua")
  records = jsonencode([
    {
      name    = "entry-internal.infra"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.alb.outputs.lb_dns_name]
    },
    {
      name = "web.cmd"
      type = "A"
      alias = {
        name    = "dualstack.${dependency.alb.outputs.lb_dns_name}"
        zone_id = dependency.alb.outputs.lb_zone_id
      }
    }
  ])
}
