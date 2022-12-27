include {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
dependency "zone" {
  # Hardcode!
  config_path = "../uat.data.rbua-zones/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.9.0"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  envcommon    = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.project_vars.locals.project_tags
}
inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "uat.data.rbua")
  records = jsonencode([
    {
      name    = "terraform"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-134-106.eu-central-1.compute.internal"]
    },
    {
      name    = "nifi"
      type    = "CNAME"
      ttl     = 3600
      records = ["internal-rbua-data-uat-nifi-alb-93519504.eu-central-1.elb.amazonaws.com"]
    },
    {
      name    = "nifi-registry"
      type    = "CNAME"
      ttl     = 3600
      records = ["internal-rbua-data-uat-nifi-alb-93519504.eu-central-1.elb.amazonaws.com"]
    }
  ])
}
