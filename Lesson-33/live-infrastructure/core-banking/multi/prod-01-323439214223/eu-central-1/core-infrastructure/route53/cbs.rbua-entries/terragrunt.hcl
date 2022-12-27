include {
  path = find_in_parent_folders()
}

dependency "zone" {
  # Hardcode!
  config_path = "../cbs.rbua-zones/"
}

dependency "alb" {
  # Hardcode!
  config_path = "../../../lb/application-entrypoint/alb"
}

dependency "b2_nlb" {
  # Hardcode!
  config_path = "../../../lb/db-entrypoint/b2_nlb"
}

dependency "abs_nlb" {
  # Hardcode!
  config_path = "../../../lb/db-entrypoint/abs_nlb"
}

dependency "cisaod_nlb" {
  # Hardcode!
  config_path = "../../../lb/db-entrypoint/cisaod_nlb"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}
iam_role = local.account_vars.iam_role

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map    = local.common_tags.locals
}

inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "cbs.rbua")
  records = jsonencode([
    {
      name    = "entrypoint-app"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.alb.outputs.lb_dns_name]
    },
    {
      name    = "entrypoint-db-b2"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.b2_nlb.outputs.lb_dns_name]
    },
    {
      name    = "xml-app.b2"
      type    = "CNAME"
      ttl     = 3600
      records = ["entrypoint-app.cbs.rbua"]
    },
    {
      name    = "xml-app01.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.250"]
    },
    {
      name    = "xml-app02.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.8"]
    },
    {
      name    = "jet-app.b2"
      type    = "CNAME"
      ttl     = 3600
      records = ["entrypoint-app.cbs.rbua"]
    },
    {
      name    = "jet-app01.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.235"]
    },
    {
      name    = "jet-app02.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.51"]
    },
    {
      name = "lrt-db.b2"
      type = "CNAME"
      ttl  = 3600
      #      records        = ["entrypoint-db-b2.cbs.rbua"]
      records = ["lrt-db02.b2.cbs.rbua"]
    },
    {
      name    = "lrt-db01.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.54"]
    },
    {
      name    = "morrowind-app.ci"
      type    = "CNAME"
      ttl     = 3600
      records = ["entrypoint-app.cbs.rbua"]
    },
    {
      name    = "morrowind-app01.ci"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.196"]
    },
    {
      name    = "morrowind-app02.ci"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.32"]
    },
    {
      name    = "disco-adm.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.241"]
    },
    {
      name    = "director-app.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.204"]
    },
    {
      name    = "app01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.36"]
    },
    {
      name    = "celer"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.205"]
    },
    {
      name    = "tech01.ctm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.254"]
    },
    {
      name    = "tech08.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.215"]
    },
    {
      name    = "tech10.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.229"]
    },
    {
      name    = "tech06.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.236"]
    },
    {
      name    = "tech07.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.221"]
    },
    {
      name    = "tech02.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.251"]
    },
    {
      name    = "tech13.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.213"]
    },
    {
      name    = "tech09.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.240"]
    },
    {
      name    = "tech14.ci"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.207"]
    },
    {
      name    = "tech12-ho.cish"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.202"]
    },
    {
      name    = "tech12-od.sh"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.211"]
    },
    {
      name    = "tech12-lv.sh"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.222"]
    },
    {
      name    = "tech12-kh.sh"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.239"]
    },
    {
      name    = "tech12-dp.sh"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.237"]
    },
    {
      name    = "tech12-kv.sh"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.253"]
    },
    {
      name    = "app02.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.220"]
    },
    {
      name    = "app03.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.37"]
    },
    {
      name    = "app04.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.210"]
    },
    {
      name    = "app05.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.25"]
    },
    {
      name    = "app06.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.230"]
    },
    {
      name    = "glassf-app"
      type    = "CNAME"
      ttl     = 3600
      records = ["entrypoint-app.cbs.rbua"]
    },
    {
      name    = "glassf-app01"
      type    = "A"
      ttl     = 3600
      records = ["10.226.131.44"]
    },
    {
      name    = "glassf-app02"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.209"]
    },
    {
      name    = "abs-db01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.28"]
    },
    {
      name    = "abs-db02.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.108"]
    },
    {
      name    = "abs2-db01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.32"]
    },
    {
      name    = "entrypoint-db-abs"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.abs_nlb.outputs.lb_dns_name]
    },
    {
      name    = "abs-db.bm"
      type    = "CNAME"
      ttl     = 3600
      records = ["entrypoint-db-abs.cbs.rbua"]
    },
    {
      name    = "gate2-db01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.225.112.78"]
    },
    {
      name    = "barsep-db01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.15"]
    },
    {
      name    = "bmarch-db01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.108.97"]
    },
    {
      name    = "ansible.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.216"]
    },
    {
      name    = "arch-db01.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.47"]
    },
    {
      name    = "barsep-db02.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.77"]
    },
    {
      name    = "cisaod-db01.ci"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.48"]
    },
    {
      name    = "cisaod-db02.ci"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.119"]
    },
    {
      name = "cisaod-db.ci"
      type = "A"
      ttl  = 3600
      #      records        = ["entrypoint-db-cisaod.cbs.rbua"]
      records = ["10.226.130.48"]
    },
    {
      name    = "entrypoint-db-cisaod"
      type    = "CNAME"
      ttl     = 3600
      records = [dependency.cisaod_nlb.outputs.lb_dns_name]
    },
    {
      name    = "lrt-db02.b2"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.174"]
    },
    {
      name    = "relay-app01"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.46"]
    },
    {
      name    = "relay"
      type    = "CNAME"
      ttl     = 3600
      records = ["relay-app01.cbs.rbua"]
    },
    {
      name    = "pgraf-mon"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.198"]
    },
    {
      name    = "gate-db02.bm"
      type    = "A"
      ttl     = 3600
      records = ["10.226.130.102"]
    }
    ]
  )
}
