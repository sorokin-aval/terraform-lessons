include {
  path = find_in_parent_folders()
}
include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}
dependency "zone" {
  # Hardcode!
  config_path = "../prod.data.rbua-zones/"
}

#dependency "alb" {
#  # Hardcode!
#  config_path = "../../alb-entrypoint-internal/alb/"
#}


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

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "data.rbua")
  records = jsonencode([
    {
      name    = "terraform"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-134-106.eu-central-1.compute.internal"]
    },
    {
      name    = "sota-ap01"
      type    = "A"
      ttl     = 3600
      records = ["10.226.155.6"]
    },
    {
      name    = "sota-ap02"
      type    = "A"
      ttl     = 3600
      records = ["10.226.155.54"]
    },
    {
      name    = "sota-mydb"
      type    = "CNAME"
      ttl     = 3600
      records = ["sota.chavqwvbnvim.eu-central-1.rds.amazonaws.com"]
    },
    {
      name    = "mebius-db03"
      type    = "A"
      ttl     = 600
      records = ["10.226.155.92"]
    },
    {
      name    = "mebius-db02"
      type    = "A"
      ttl     = 600
      records = ["10.226.155.112"]
    },
    {
      name    = "sota-db01"
      type    = "A"
      ttl     = 600
      records = ["10.226.155.73"]
    },
    {
      name    = "sota-db02"
      type    = "A"
      ttl     = 600
      records = ["10.226.155.125"]
    },
    {
      name    = "das.vicont"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.8", "10.226.155.61", "10.226.155.28", "10.226.155.46", "10.226.155.14"]
    },
    {
      name    = "das.vicont"
      type    = "TXT"
      ttl     = 300
      records = ["DNS Balancer for Vicont"]
    },
    {
      name    = "das01.vicont"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.8"]
    },
    {
      name    = "das02.vicont"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.61"]
    },
    {
      name    = "das03.vicont"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.28"]
    },
    {
      name    = "das04.vicont"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.46"]
    },
    {
      name    = "das05.vicont"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.14"]
    },
    {
      name    = "vatauto-ap01"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.27"]
    },
    {
      name    = "vatauto-ap02"
      type    = "A"
      ttl     = 300
      records = ["10.226.155.50"]
    }
  ])
}
