include {
  path = find_in_parent_folders()
}

dependency "zone" {
  # Hardcode!
  config_path = "../prod.rbua-zones/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals

}

inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "odb.rbua")
  records = jsonencode([
    {
      name           = "mess"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "mess-db01"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "mess-db02"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "auth"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "dvo"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "int"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "leis"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "letran"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "leauth"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "csk"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "ft"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "cmess"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "dixsoc"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "piarch"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multipixel.inet-dmz.kv.aval"]
    },
    {
      name           = "lepte"
      type           = "CNAME"
      ttl            = 3600
      records        = ["multirock.odb.kv.aval"]
    },
  ])
}