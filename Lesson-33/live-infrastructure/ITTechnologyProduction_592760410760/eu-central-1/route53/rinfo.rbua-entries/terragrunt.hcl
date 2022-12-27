include {
  path = find_in_parent_folders()
}

dependency "zone" {
  # Hardcode!
  config_path = "../rbua-zones/"
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
}

inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "rinfo.rbua")
  records = jsonencode([
    {
      name           = "ap02"
      type           = "A"
      ttl            = 3600
      records        = ["10.226.108.163"]
    },
    {
      name           = "ap01"
      type           = "A"
      ttl            = 3600
      records        = ["10.226.108.69"]
    },  
  ])
}