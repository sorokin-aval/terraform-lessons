include {
  path = find_in_parent_folders()
}

dependency "zone" {
  # Hardcode!
  config_path = "../its.rbua-zones/"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
}

inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "its.rbua")
  records = jsonencode([
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 3600
      records        = ["google.com"]
    },
    {
      name           = "icap"
      type           = "CNAME"
      ttl            = 3600
      records        = ["icap-nlb-773dd779dbb3322c.elb.eu-central-1.amazonaws.com"]
    },
    {
      name           = "esm-aws"
      type           = "A"
      ttl            = 3600
      records        = ["10.226.114.75"]
    },
    {
      name           = "checkit"
      type           = "CNAME"
      ttl            = 3600
      records        = ["validationd-nlb-d8890408b2537f4b.elb.eu-central-1.amazonaws.com"]
    },
    {
      name           = "proxy"
      type           = "CNAME"
      ttl            = 3600
      records        = ["proxy-nlb-1ebb4e431d98de79.elb.eu-central-1.amazonaws.com"]
    },
    {
      name           = "trunkc"
      type           = "A"
      ttl            = 3600
      records        = ["10.226.113.82"]
    },
    {
      name           = "one-app"
      type           = "CNAME"
      ttl            = 3600
      records        = ["internal-ONE-APP-ALB-1740616311.eu-central-1.elb.amazonaws.com"]
    },
    {
      name           = "oneidm-db"
      type           = "CNAME"
      ttl            = 3600
      records        = ["ONEIDM-DB-NLB-16cea1ed9acf5cee.elb.eu-central-1.amazonaws.com"]
    },
    {
      name           = "ise1"
      type           = "A"
      ttl            = 3600
      records        = ["10.226.113.36"]
    },
    {
      name           = "ise2"
      type           = "A"
      ttl            = 3600
      records        = ["10.226.113.75"]
    },
    {
      name           = "isenlb"
      type           = "CNAME"
      ttl            = 3600
      records        = ["CiscoISE-nlb-7803635a40b4e385.elb.eu-central-1.amazonaws.com"]
    },
    {
      name           = "aws-ldaps"
      type           = "CNAME"
      ttl            = 3600
      records        = ["ldaps-aws-nlb-817f4b044e4ab9af.elb.eu-central-1.amazonaws.com"]
    },
    {
      name           = "typex"
      type           = "CNAME"
      ttl            = 3600
      records        = ["typex.ms.aval"]
    },
    {
      name           = "pki"
      type           = "CNAME"
      ttl            = 3600
      records        = ["enigma.ms.aval"]
    },
    {
      name           = "ocsp"
      type           = "CNAME"
      ttl            = 3600
      records        = ["ocsp.ms.aval"]
    },
    {
      name           = "ndes"
      type           = "CNAME"
      ttl            = 3600
      records        = ["ndes.ms.aval"]
    },
    {
      name           = "argo-general-prod"
      type           = "CNAME"
      ttl            = 3600
      records        = ["k8s-ingressn-ingressn-90155d0201-a209d7cdbd95874d.elb.eu-central-1.amazonaws.com"]
    }
  ])
}
