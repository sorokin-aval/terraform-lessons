include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "zone" {
  config_path = find_in_parent_folders("zone")
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.9.0"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  #Tags in order ->(root folder)-> tags_common.hcl ->(current folder)-> tags.hcl
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags_common.hcl"))
  local_tags    = read_terragrunt_config("tags.hcl", {locals = {tags={}}})
  tags_map      = merge(local.common_tags.locals.tags, local.local_tags.locals.tags)
  
  zone_name     = basename(dirname(get_terragrunt_dir()))
}

inputs   = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.zone_name)

  records = jsonencode([
    {
      name    = "aws-bktvbv"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-144-107.eu-central-1.compute.internal"]
    },
    {
      name    = "console-sh"
      type    = "A"
      ttl     = 3600
      records = ["10.226.148.6",]
    },
    {
      name    = "aws-dc01"
      type    = "A"
      ttl     = 3600
      records = ["10.227.50.190",]
    },
    {
      name    = "aws-dc02"
      type    = "A"
      ttl     = 3600
      records = ["10.227.50.197",]
    },
    {
      name    = "ds"
      type    = "A"
      ttl     = 3600
      records = ["10.227.50.141","10.227.50.149",]
    },
    {
      name    = "aws-ldaps"
      type    = "CNAME"
      ttl     = 3600
      records = ["rbua-ldaps-nlb-9b2ddaf717e368ae.elb.eu-central-1.amazonaws.com"]
    }
  ])
}
