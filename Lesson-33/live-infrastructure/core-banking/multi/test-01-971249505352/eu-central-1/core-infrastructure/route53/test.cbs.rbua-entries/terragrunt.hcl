include {
  path = find_in_parent_folders()
}

dependency "zone" {
  # Hardcode!
  config_path = "../test.cbs.rbua-zones/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
}

iam_role = local.account_vars.iam_role

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
}


inputs = {

  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, "test.cbs.rbua")
  records = jsonencode([
    {
      name           = "preb2"
      type           = "A"
      ttl            = 3600
      records        = ["10.227.52.247"]
    },
    {
      name           = "xmlb2"
      type           = "A"
      ttl            = 3600
      records        = ["10.227.52.150"]
    },
    {
      name           = "jetb2"
      type           = "A"
      ttl            = 3600
      records        = ["10.227.52.142"]
<<<<<<< Updated upstream
=======
    },
    {
      name           = "bm6db"
      type           = "CNAME"
      ttl            = 3600
      records        = ["bmaster-6.cozkfv3ohtwl.eu-central-1.rds.amazonaws.com"]
    },
    {
      name           = "win10-airflow"
      type           = "A"
      ttl            = 3600
      records        = ["10.227.52.88"]
    },
    {
      name           = "win10-dbadm"
      type           = "A"
      ttl            = 3600
      records        = ["10.227.52.151"]
>>>>>>> Stashed changes
    }

  ]
)
}

